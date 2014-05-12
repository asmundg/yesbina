# -*- encoding: utf-8 -*-
from __future__ import unicode_literals

import hy  # noqa
import pytest
import vcr

import yesbina.xmpp


def test_fmt():
    assert (yesbina.xmpp.fmt(
        [dict(
            stop='Tromsdalen Bruvegen (Troms\xf8)',
            departures=[dict(
                line='28',
                destination='mot Bj\xf8rnebekken',
                time='2014-04-26T09:01:00+02:00')])])
            == 'Tromsdalen Bruvegen -> Bj\xf8rnebekken @ 09:01')

@pytest.mark.system
@vcr.use_cassette('vcr/line-stop.yaml')
def test_line_stop():
    assert (yesbina.xmpp.fmt(yesbina.xmpp.dispatch('28 oter'))
            == 'Otervegen -> Solligården @ 07:53\n'
            'Otervegen -> Sentrum @ 08:03\n'
            'Otervegen -> Solligården @ 08:13\n'
            'Otervegen -> Solligården @ 08:33\n'
            'Otervegen -> Solligården @ 08:53\n'
            'Otervegen -> Solligården @ 09:13\n'
            'Otervegen -> Solligården @ 09:43\n'
            'Otervegen -> Solligården @ 10:13\n'
            'Otervegen -> Solligården @ 10:43\n'
            'Otervegen -> Solligården @ 11:13')
