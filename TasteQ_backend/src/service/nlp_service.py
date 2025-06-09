from eunjeon import Mecab

# 직접 설치한 mecab-ko-dic 경로로 명시
mecab = Mecab("--rcfile=/usr/local/lib/mecab/mecab-ko-dic/mecabrc")

def extract_nouns(text: str) -> list[str]:
    return mecab.nouns(text)
