from bs4 import BeautifulSoup
from .. import line


def test_find_tripno_default():
    assert line.find_tripno(BeautifulSoup('')) is None
