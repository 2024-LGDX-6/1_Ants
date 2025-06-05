from fastapi import WebSocket
from google.cloud import speech_v1p1beta1 as speech
import asyncio
from eunjeon import Mecab
import json
from service.recipe_service import get_recipes_by_main_ingredients,get_recipes_by_name
from service.custom_recipe_service import get_custom_recipes_by_main_ingredients,get_custom_recipes_by_name
from database.connection import get_connection

from dotenv import load_dotenv
import os

load_dotenv()
cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
print("✅ ENV PATH:", cred_path)
print("✅ ABS PATH:", os.path.abspath(cred_path))
print("✅ FILE EXISTS?", os.path.exists(cred_path))



mecab = Mecab()

def get_all_recipe_names() -> set[str]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # 표준 레시피 이름
            cursor.execute("SELECT recipe_name FROM recipe")
            recipe_names = set(row['recipe_name'] for row in cursor.fetchall())

            # 커스텀 레시피 이름
            cursor.execute("SELECT custom_recipe_name FROM custom_recipe")
            custom_names = set(row['custom_recipe_name'] for row in cursor.fetchall())

            return recipe_names.union(custom_names)
    finally:
        conn.close()


def get_all_main_ingredients() -> set[str]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # 표준 레시피 재료
            cursor.execute("SELECT DISTINCT main_ingredient FROM recipe")
            ingredients = set(row['main_ingredient'] for row in cursor.fetchall())

            # 커스텀 레시피 재료
            cursor.execute("SELECT DISTINCT custom_main_ingredient FROM custom_recipe")
            custom_ingredients = set(row['custom_main_ingredient'] for row in cursor.fetchall())

            return ingredients.union(custom_ingredients)
    finally:
        conn.close()

def get_recommendations_by_nouns(nouns: list[str]) -> dict:
    recipe_names = get_all_recipe_names()
    ingredients = get_all_main_ingredients()

    matched_recipes = [n for n in nouns if n in recipe_names]
    matched_ingredients = [n for n in nouns if n in ingredients]

    standard_recipe_result = []
    custom_recipe_result = []

    if matched_recipes:
        standard_recipe_result = get_recipes_by_name(matched_recipes)
        custom_recipe_result = get_custom_recipes_by_name(matched_recipes)
    elif matched_ingredients:
        standard_recipe_result = get_recipes_by_main_ingredients(matched_ingredients)
        custom_recipe_result = get_custom_recipes_by_main_ingredients(matched_ingredients)

    return {
        "standard_recipes": standard_recipe_result,
        "custom_recipes": custom_recipe_result
    }






async def handle_stt_stream(websocket: WebSocket):
    await websocket.accept()
    client = speech.SpeechClient()

    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code="ko-KR"
    )
    streaming_config = speech.StreamingRecognitionConfig(
        config=config,
        interim_results=True
    )

    async def request_gen():
        while True:
            try:
                data = await asyncio.wait_for(websocket.receive_bytes(), timeout=15.0)
                yield speech.StreamingRecognizeRequest(audio_content=data)
            except asyncio.TimeoutError:
                print("🛑 무음 상태로 15초 경과 → 스트림 종료")
                break
            except Exception as e:
                print("❌ WebSocket receive error:", e)
                break

    try:
        responses = client.streaming_recognize(config=streaming_config, requests=request_gen())
        for response in responses:
            for result in response.results:
                transcript = result.alternatives[0].transcript

                # 🧠 STEP 3: interim 결과 전송
                await websocket.send_text(json.dumps({
                    "type": "interim",
                    "text": transcript
                }))

                if result.is_final:

                    nouns = mecab.nouns(transcript)
                    recommendations = get_recommendations_by_nouns(nouns)

                    await websocket.send_text(json.dumps({
                        "type": "final",
                        "text": transcript,
                        "nouns": nouns,
                        "recommendations": recommendations
                    }))


    except Exception as e:
        print("Google STT Error:", e)
        await websocket.send_text(f"ERROR: {str(e)}")
