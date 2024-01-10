#!/usr/bin/env python

from argparse import ArgumentParser, Namespace
from copy import deepcopy
from datetime import date
from io import StringIO
from typing import Final, List, Optional, Tuple

from korean_lunar_calendar import KoreanLunarCalendar

SUPPORT_YEAR_RANGE_MIN: Final[int] = 1000
SUPPORT_YEAR_RANGE_MAX: Final[int] = 2050
SUPPORT_YEAR_RANGE: Tuple[int, int] = (SUPPORT_YEAR_RANGE_MIN, SUPPORT_YEAR_RANGE_MAX)
"""
한국 양음력 변환 (한국천문연구원 기준) - 네트워크 연결 불필요
음력 변환은 1000년 01월 01일 부터 2050년 11월 18일까지 지원
양력 변환은 1000년 02월 13일 부터 2050년 12월 31일까지 지원
"""

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

ENABLE_INTERCALATION = False
"""
윤달 또는 윤월(閏月) 여부
"""

GRANDFATHER_DEATH_ANNIVERSARY: Final[date] = date(1986, 8, 6)
GRANDMA_DEATH_ANNIVERSARY: Final[date] = date(2010, 5, 23)


class Trans:
    def __init__(self, ko: str, ch: str):
        self.ko = ko
        self.ch = ch

    def as_list(self) -> List[str]:
        result = []
        for ch, ko in zip(self.ch, self.ko):
            result.append(f"{ch}({ko})")
        return result


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
        is_intercalation=ENABLE_INTERCALATION,
    ):
        self._calendar = KoreanLunarCalendar()
        self._calendar.setLunarDate(year, month, day, is_intercalation)

        self.gapja_ko = deepcopy(self._calendar.getGapJaString())
        self.gapja_ch = deepcopy(self._calendar.getChineseGapJaString())

        self.sexagenary_cycle = Trans(self.gapja_ko, self.gapja_ch)
        ko_y, ko_m, ko_d = self.gapja_ko.split()
        ch_y, ch_m, ch_d = self.gapja_ch.split()

        self.tai_sui = Trans(ko_y, ch_y)
        self.day_of_death = Trans(ko_d, ch_d)

        first_day_calendar = KoreanLunarCalendar()
        first_day_calendar.setLunarDate(year, month, 1, is_intercalation)
        first_day_gapja_ko = first_day_calendar.getGapJaString()
        first_day_gapja_ch = first_day_calendar.getChineseGapJaString()
        first_day_ko_day = first_day_gapja_ko.split()[2]
        first_day_ch_day = first_day_gapja_ch.split()[2]
        assert len(first_day_ko_day) == len(first_day_ch_day)
        self.first_day_of_the_month = Trans(first_day_ko_day, first_day_ch_day)

    @property
    def year(self) -> int:
        return self._calendar.lunarYear

    @property
    def month(self) -> int:
        return self._calendar.lunarMonth

    @property
    def day(self) -> int:
        return self._calendar.lunarDay

    @property
    def solar(self) -> str:
        return self._calendar.SolarIsoFormat()

    @property
    def lunar(self) -> str:
        return self._calendar.LunarIsoFormat()

    @property
    def section1(self) -> List[str]:
        return ["歲(세)", "次(차)"] + self.tai_sui.as_list()

    @property
    def section2(self) -> List[str]:
        day = self.first_day_of_the_month.as_list()
        return list(HANJA_NUMBERS[self.month]) + ["月(월)"] + day + ["朔(삭)"]

    @property
    def section3(self) -> List[str]:
        day = self.day_of_death.as_list()
        return list(HANJA_NUMBERS[self.day]) + ["日(일)"] + day

    def as_list(self) -> List[str]:
        return self.section1 + [""] + self.section2 + [""] + self.section3

    def __str__(self) -> str:
        buffer = StringIO()
        buffer.writelines(map(lambda x: x + "\n", self.as_list()))
        return buffer.getvalue()


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
    default_year: Optional[int] = None,
) -> Namespace:
    parser = ArgumentParser(prog="opy-written-prayer")
    parser.add_argument(
        "--all",
        "-a",
        action="store_true",
        help="Prints all remaining years from the entered year",
    )
    parser.add_argument(
        "year",
        nargs="?",
        default=default_year,
        type=int,
        help=f"Year (default: {default_year})",
    )
    return parser.parse_known_args(cmdline, namespace)[0]


def print_written_prayer(name: str, year: int, month: int, day: int) -> None:
    if year < SUPPORT_YEAR_RANGE_MIN or SUPPORT_YEAR_RANGE_MAX < year:
        raise ValueError("Unsupported year")

    info = LunarInfo(year, month, day)
    print(f"{name} [{info.lunar}]")
    print(str(info))


def print_all_written_prayer(year: int) -> None:
    print_written_prayer(
        name="Grandma",
        year=year,
        month=GRANDMA_DEATH_ANNIVERSARY.month,
        day=GRANDMA_DEATH_ANNIVERSARY.month,
    )
    print_written_prayer(
        name="Grandfather",
        year=year,
        month=GRANDFATHER_DEATH_ANNIVERSARY.month,
        day=GRANDFATHER_DEATH_ANNIVERSARY.day,
    )


def main() -> None:
    args = get_default_arguments(default_year=date.today().year)
    assert isinstance(args.all, bool)
    assert isinstance(args.year, int)
    if args.all:
        for year in range(args.year, SUPPORT_YEAR_RANGE_MAX + 1):
            print_all_written_prayer(year)
    else:
        print_all_written_prayer(args.year)


if __name__ == "__main__":
    main()
