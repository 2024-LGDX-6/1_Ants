from eunjeon import Mecab

mecab = Mecab()

def extract_nouns(text: str) -> list[str]:
    return mecab.nouns(text)