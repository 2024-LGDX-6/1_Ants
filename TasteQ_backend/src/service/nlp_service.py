from eunjeon import Mecab

# ✅ mecabrc 파일이 들어 있는 디렉토리만 경로로 사용
mecab = Mecab("/usr/local/lib/mecab/mecab-ko-dic")

def extract_nouns(text: str) -> list[str]:
    return mecab.nouns(text)