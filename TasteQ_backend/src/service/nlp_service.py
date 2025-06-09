from eunjeon import Mecab
import mecab_ko_dic  # pip install python-mecab-ko-dic 필요

# 사전 경로 자동 설정
mecab = Mecab(mecab_ko_dic.dictionary_path)

def extract_nouns(text: str) -> list[str]:
    return mecab.nouns(text)
