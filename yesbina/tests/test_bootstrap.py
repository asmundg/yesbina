from __future__ import unicode_literals

import hy  # noqa
import vcr

from yesbina import bootstrap

@vcr.use_cassette('vcr/important-stops-for-line.yaml')
def test_important_stops_for_line():
    assert bootstrap.important_stops_for_line(28) == [
        'Tromsdalen Bruvegen (Troms\xf8)',
        'Petersborggata (Troms\xf8)',
        'Hamna skole \xf8st (Troms\xf8)',
        'Sj\xf8gata S2 (Troms\xf8)',
        'Fr. Langes gate F4 (Troms\xf8)',
        'Postterminalen (Troms\xf8)',
        'Fiskekroken (Troms\xf8)',
        'Vervarslinga (Troms\xf8)',
        'Skippergata (Troms\xf8)',
        'Pyramiden (Troms\xf8)',
        'Gi\xe6verbukta (Troms\xf8)',
        'Torgcenteret (Troms\xf8)']
