import os
from google.cloud import speech
from dotenv import load_dotenv

load_dotenv()
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

def transcribe_audio(audio_bytes: bytes) -> str:
    try:
        client = speech.SpeechClient()

        audio = speech.RecognitionAudio(content=audio_bytes)
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,  # WAV (PCM)
            sample_rate_hertz=16000,  # 녹음 환경에 따라 조정
            language_code="ko-KR"
        )

        response = client.recognize(config=config, audio=audio)

        transcript = ""
        for result in response.results:
            transcript += result.alternatives[0].transcript

        return transcript or "(인식된 텍스트 없음)"

    except Exception as e:
        return f"[ERROR] {str(e)}"
