"""
Step 1:
For realtime speech-to-text:
Sign up for a Free AssemblyAI API Key: 
https://www.assemblyai.com/?utm_source=youtube&utm_medium=referral&utm_campaign=yt_smit_28

For DeepSeek's R1 model:
Download Ollama: https://ollama.com

For text-to-speech:
Sign up for ElevenLabs

Install PortAudio, which is required for real-time transcription:  

    Debian/Ubuntu: apt install portaudio19-dev  
    MacOS: brew install portaudio 

Additionally, Install Python Libraries  
Before running this script, install the required dependencies:

    pip install "assemblyai[extras]" 
    pip install ollama
    pip install elevenlabs 

If you're on MacOS, also install MPV for audio streaming:  

    brew install mpv

Step 2: Download the DeepSeek R1 Model  
Since this script uses DeepSeek R1 via Ollama, download the model locally by running:  

    ollama pull deepseek-r1:7b

Step 3: Real-Time Transcription with AssemblyAI  
The script captures real-time audio from the microphone and converts speech to text using AssemblyAI.  
This transcription is then sent to the AI model for processing.  

Step 4: AI Response with DeepSeek R1  
Once a transcript is generated, it is sent to DeepSeek R1 (7B model) via Ollama.  
The model generates a response, which is then converted into speech using ElevenLabs.  

Step 5: Live Audio Streaming  
The generated response is streamed back to the user in real-time as speech, using ElevenLabs' text-to-speech engine.  
"""
import assemblyai as aai
from elevenlabs.client import ElevenLabs
from elevenlabs import stream
import ollama
import constants

class AIVoiceAgent:
    def __init__(self):
        aai.settings.api_key = constants.ASSEMBLYAI_API_KEY
        self.client = ElevenLabs(
            api_key = constants.ELEVENLABS_API_KEY
        )

        self.transcriber = None

        self.full_transcript = [
            {"role":"system", "content":"You are a language model called R1 created by DeepSeek, answer the questions being asked in less than 300 characters."},
        ]

    def start_transcription(self):
        print(f"\nReal-time transcription: ", end="\r\n")
        self.transcriber = aai.RealtimeTranscriber(
          sample_rate=16_000,
          on_data=self.on_data,
          on_error=self.on_error,
          on_open=self.on_open,
          on_close=self.on_close,
      )
        self.transcriber.connect()
        microphone_stream = aai.extras.MicrophoneStream(sample_rate=16_000)
        self.transcriber.stream(microphone_stream)

    def stop_transcription(self):
      if self.transcriber:
          self.transcriber.close()
          self.transcriber = None

    def on_open(self, session_opened: aai.RealtimeSessionOpened):
        #print("Session ID:", session_opened.session_id)
        return
    
    def on_data(self, transcript: aai.RealtimeTranscript):
        if not transcript.text:
            return

        if isinstance(transcript, aai.RealtimeFinalTranscript):
            print(transcript.text)
            self.generate_ai_response(transcript)
        else:
            print(transcript.text, end="\r")

    def on_error(self, error: aai.RealtimeError):
        #print("An error occured:", error)
        return

    def on_close(self):
        #print("Closing Session")
        return    
    
    def generate_ai_response(self, transcript):
        self.stop_transcription()

        self.full_transcript.append({"role":"user", "content":transcript.text})
        print(f"\nUser:{transcript.text}", end="\r\n")

        ollama_stream = ollama.chat(
            model = "deepseek-r1:7b",
            messages = self.full_transcript,
            stream = True,
        )

        print("DeepSeek R1:", end="\r\n")
        text_buffer = ""
        full_text = ""
        for chunk in ollama_stream:
            text_buffer += chunk['message']['content']
            if text_buffer.endswith('.'):
                audio_stream = self.client.generate(text=text_buffer,
                                                    model="eleven_turbo_v2",
                                                    stream=True)
                print(text_buffer, end="\n", flush=True)
                stream(audio_stream)
                full_text += text_buffer
                text_buffer = ""

        if text_buffer:
            audio_stream = self.client.generate(text=text_buffer,
                                                    model="eleven_turbo_v2",
                                                    stream=True)
            print(text_buffer, end="\n", flush=True)
            stream(audio_stream)
            full_text += text_buffer

        self.full_transcript.append({"role":"assistant", "content":full_text})

        self.start_transcription()

ai_voice_agent = AIVoiceAgent()
ai_voice_agent.start_transcription()
