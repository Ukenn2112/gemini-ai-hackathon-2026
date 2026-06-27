import os
import logging
from flask import Flask, request, jsonify, render_template, send_from_directory
from dotenv import load_dotenv

# Load environment variables from .env file if it exists (for local development)
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__, static_folder="static", template_folder="templates")

# Initialize Gemini Client if API key is in environment
# On Cloud Run, this environment variable should be set natively.
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

def run_adk_agent(prompt, api_key=None):
    import asyncio
    
    async def _run():
        original_key = os.environ.get("GEMINI_API_KEY")
        key_to_use = api_key or GEMINI_API_KEY
        if key_to_use:
            os.environ["GEMINI_API_KEY"] = key_to_use
        
        try:
            from google.adk.agents import LlmAgent
            from google.adk.runners import InMemoryRunner
            from google.genai import types

            # Define the agent with instruction and model
            agent = LlmAgent(
                name="hello_agent",
                model="gemini-2.0-flash",
                instruction="You are a helpful assistant. Greet the user warmly and answer their query."
            )
            
            # Setup runner with auto-create session
            runner = InMemoryRunner(agent=agent)
            runner.auto_create_session = True

            # Prepare message
            msg = types.Content(parts=[types.Part.from_text(text=prompt)])
            text_parts = []
            error_msg = None

            # Stream response events from the agent
            async for event in runner.run_async(
                user_id="default_user",
                session_id="default_session",
                new_message=msg
            ):
                if event.error_message:
                    error_msg = event.error_message
                    break
                if event.content and event.content.parts:
                    for part in event.content.parts:
                        if part.text:
                            text_parts.append(part.text)

            if error_msg:
                return {"success": False, "error": error_msg}
            
            return {"success": True, "text": "".join(text_parts)}
            
        except Exception as e:
            logger.exception("Error in ADK run:")
            return {"success": False, "error": str(e)}
        finally:
            if key_to_use:
                if original_key is not None:
                    os.environ["GEMINI_API_KEY"] = original_key
                else:
                    os.environ.pop("GEMINI_API_KEY", None)

    return asyncio.run(_run())

@app.route("/")
def index():
    has_api_key = GEMINI_API_KEY is not None
    return render_template("index.html", has_api_key=has_api_key)

@app.route("/api/generate", methods=["POST"])
def generate():
    data = request.json or {}
    prompt = data.get("prompt", "")
    custom_api_key = data.get("apiKey", "").strip()

    if not prompt:
        return jsonify({"error": "Prompt is required"}), 400

    # Execute request via Google ADK Agent
    result = run_adk_agent(prompt, custom_api_key)
    
    if not result.get("success"):
        return jsonify({"error": result.get("error")}), 500
        
    return jsonify({
        "success": True,
        "text": result.get("text"),
        "model": "gemini-2.0-flash (via Google ADK)"
    })

# Health check endpoint for Cloud Run
@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    # Get port from environment or default to 8080 (standard for Cloud Run)
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=True)
