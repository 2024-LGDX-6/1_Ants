from eunjeon import Mecab

mecab = Mecab("/usr/local/lib/mecab/dic/mecab-ko-dic")  # ✅ 경로 명시

def extract_nouns(text: str) -> list[str]:
    return mecab.nouns(text)