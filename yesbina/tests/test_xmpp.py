from __future__ import unicode_literals

import hy  # noqa

import yesbina.xmpp


def test_fmt():
    assert (yesbina.xmpp.fmt(
        [dict(
            stop='Tromsdalen Bruvegen (Troms\xf8)',
            departure=dict(
                line='28',
                destination='mot Bj\xf8rnebekken',
                time='2014-04-26T09:01:00+02:00'))])
            == 'Tromsdalen Bruvegen -> Bj\xf8rnebekken @ 09:01')
