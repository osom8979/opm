#!/usr/bin/env python

from datetime import datetime
from korean_lunar_calendar import KoreanLunarCalendar

def printInformation(year, is_intercalation=False):
    today = datetime.today()
    year = today.year
    month = today.month
    day = today.day
    calendar = KoreanLunarCalendar()
    calendar.setSolarDate(year, month, day)

    print('Year: {}'.format(year))

    # 할머니: (음) 5/23
    calendar.setLunarDate(year, 5, 23, is_intercalation)
    print('할머니 제사 (음) 5/23')
    print('* Solar: {}'.format(calendar.SolarIsoFormat()))
    print('* Lunar: {}'.format(calendar.LunarIsoFormat()))
    print('* Hangul: {}'.format(calendar.getGapJaString()))
    print('* Hanja: {}'.format(calendar.getChineseGapJaString()))

    calendar.setLunarDate(year, 5, 1, is_intercalation)
    print('초하루 (음) 5/1')
    print('* Solar: {}'.format(calendar.SolarIsoFormat()))
    print('* Lunar: {}'.format(calendar.LunarIsoFormat()))
    print('* Hangul: {}'.format(calendar.getGapJaString()))
    print('* Hanja: {}'.format(calendar.getChineseGapJaString()))

    print('------------------------------')

    # 할아버지: (음) 8/6
    calendar.setLunarDate(year, 8, 6, is_intercalation)
    print('할아버지 제사 (음) 8/6')
    print('* Solar: {}'.format(calendar.SolarIsoFormat()))
    print('* Lunar: {}'.format(calendar.LunarIsoFormat()))
    print('* Hangul: {}'.format(calendar.getGapJaString()))
    print('* Hanja: {}'.format(calendar.getChineseGapJaString()))

    print('초하루 (음) 8/1')
    calendar.setLunarDate(year, 8, 1, is_intercalation)
    print('* Solar: {}'.format(calendar.SolarIsoFormat()))
    print('* Lunar: {}'.format(calendar.LunarIsoFormat()))
    print('* Hangul: {}'.format(calendar.getGapJaString()))
    print('* Hanja: {}'.format(calendar.getChineseGapJaString()))

# 윤달 여부
is_intercalation = False
year = 2019

printInformation(year, is_intercalation)

