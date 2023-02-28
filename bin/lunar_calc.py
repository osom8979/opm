#!/usr/bin/env python

from dataclasses import dataclass
from datetime import datetime
from io import StringIO
from korean_lunar_calendar import KoreanLunarCalendar
from typing import List, NamedTuple


HANJA_NUMBERS = {
    1: ("一(일)",),
    2: ("二(이)",),
    3: ("三(삼)",),
    4: ("四(사)",),
    5: ("五(오)",),
    6: ("六(육)",),
    7: ("七(칠)",),
    8: ("八(팔)",),
    9: ("九(구)",),
    10: ("十(십)",),
    11: ("十(십)", "一(일)"),
    12: ("十(십)", "二(이)"),
    13: ("十(십)", "三(삼)",),
    14: ("十(십)", "四(사)",),
    15: ("十(십)", "五(오)",),
    16: ("十(십)", "六(육)",),
    17: ("十(십)", "七(칠)",),
    18: ("十(십)", "八(팔)",),
    19: ("十(십)", "九(구)",),
    20: ("二(이)", "十(십)",),
    21: ("二(이)", "十(십)", "一(일)"),
    22: ("二(이)", "十(십)", "二(이)"),
    23: ("二(이)", "十(십)", "三(삼)",),
    24: ("二(이)", "十(십)", "四(사)",),
    25: ("二(이)", "十(십)", "五(오)",),
    26: ("二(이)", "十(십)", "六(육)",),
    27: ("二(이)", "十(십)", "七(칠)",),
    28: ("二(이)", "十(십)", "八(팔)",),
    29: ("二(이)", "十(십)", "九(구)",),
    30: ("三(삼)", "十(십)",),
    31: ("三(삼)", "十(십)", "一(일)"),
}
"""
한자 수사(漢字數詞)
"""

IS_INTERCALATION = False
"""
윤달 또는 윤월(閏月) 여부
"""


class Trans(NamedTuple):
    ko: str
    ch: str

    def as_list(self) -> List[str]:
        result = []
        for ch, ko in zip(self.ch, self.ko):
            result.append(f"{ch}({ko})")
        return result


@dataclass
class LunarInfo:
    tai_sui: Trans
    """
    년(年)에 해당되는 간지. 태세(太歲).
    """

    first_day_of_the_month: Trans
    """
    월(月)의 초하룻날 간지. 삭일(朔日).
    """

    day_of_death: Trans
    """
    일(日)의 간지, 즉 기일의 간지.
    """

    sexagenary_cycle: Trans
    """
    간지(干支)는 십간(十干)과 십이지(十二支)를 조합한 것으로,
    육십갑자(六十甲子)라고도 한다.
    """

    def __init__(
        self,
        year: int,
        month: int,
        day: int,
        is_intercalation=False,
    ):
        self._year = year
        self._month = month
        self._day = day
        self._calendar = KoreanLunarCalendar()
        self._calendar.setLunarDate(year, month, day, is_intercalation)

        capja_ko = self._calendar.getGapJaString()
        capja_ch = self._calendar.getChineseGapJaString()

        self.sexagenary_cycle = Trans(capja_ko, capja_ch)
        ko_y, ko_m, ko_d = capja_ko.split()
        ch_y, ch_m, ch_d = capja_ch.split()

        self.tai_sui = Trans(ko_y, ch_y)
        self.day_of_death = Trans(ko_d, ch_d)

        first_day_calendar = KoreanLunarCalendar()
        first_day_calendar.setLunarDate(year, month, 1, is_intercalation)
        first_day_capja_ko = first_day_calendar.getGapJaString()
        first_day_capja_ch = first_day_calendar.getChineseGapJaString()
        first_day_ko_day = first_day_capja_ko.split()[2]
        first_day_ch_day = first_day_capja_ch.split()[2]
        assert len(first_day_ko_day.ko) == len(first_day_ch_day.ch)
        self.first_day_of_the_month = Trans(first_day_ko_day, first_day_ch_day)

    def as_solar(self) -> str:
        return self._calendar.SolarIsoFormat()

    def as_lunar(self) -> str:
        return self._calendar.LunarIsoFormat()

    def section1(self) -> List[str]:
        return ["歲(세)", "次(차)", self.tai_sui.as_list()]

    def section2(self) -> List[str]:
        day = self.first_day_of_the_month.as_list()
        return list(HANJA_NUMBERS[self._month]) + ["月(월)"] + day + ["朔(삭)"]

    def section3(self) -> List[str]:
        day = self.day_of_death.as_list()
        return list(HANJA_NUMBERS[self._day]) + ["日(일)"] + day

    def as_list(self) -> List[str]:
        return self.section1() + self.section2() + self.section3()

    def __str__(self) -> str:
        buffer = StringIO()
        buffer.writelines(map(lambda x: x + "\n", self.as_list()))
        return buffer.getvalue()


def print_information(date, is_intercalation=False):
    year = date.year
    month = date.month
    day = date.day

    calendar = KoreanLunarCalendar()
    calendar.setSolarDate(year, month, day)

    print('Year: {}'.format(year))

    # 할머니: (음) 5/23
    calendar.setLunarDate(year, 5, 23, is_intercalation)
    print('할머니 제사 (음) 5/23')
    print('* Solar: {}'.format(calendar.SolarIsoFormat()))
    print('* Lunar: {}'.format(calendar.LunarIsoFormat()))

    hangul = calendar.getGapJaString()
    hanja = calendar.getChineseGapJaString()

    print('* Hangul: {}'.format(hangul))
    print('* Hanja: {}'.format(hanja))

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


print_information(datetime.today(), IS_INTERCALATION)
