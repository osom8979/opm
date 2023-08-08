# -*- coding: utf-8 -*-

from copy import deepcopy
from datetime import datetime, timedelta
from logging import DEBUG, Logger
from typing import Final, Optional

STEP_AVG_STRFMT: Final[str] = "[{name}] Step #{step} average duration: {avg:.3f}s"


class StepAvg:
    def __init__(
        self,
        name: str,
        logger: Logger,
        logging_step: int,
        verbose=0,
        verbose_threshold=0,
        strfmt=STEP_AVG_STRFMT,
        level=DEBUG,
        enable=True,
        clear_emitted=True,
    ):
        self._name = name
        self._logger = logger
        self._logging_step = logging_step
        self._verbose = verbose
        self._verbose_threshold = verbose_threshold
        self._strfmt = strfmt
        self._level = level
        self._enable = enable
        self._clear_emitted = clear_emitted

        self._step = 0
        self._begin = datetime.now()
        self._end = datetime.now()
        self._total = 0.0

    @property
    def name(self) -> str:
        return self._name

    @property
    def verbose(self) -> int:
        return self._verbose

    @verbose.setter
    def verbose(self, value: int):
        self._verbose = value

    @property
    def enabled(self) -> bool:
        return self._enable

    @enabled.setter
    def enabled(self, value: bool):
        self._enable = value

    @property
    def total(self) -> float:
        return self._total

    @property
    def avg(self) -> float:
        return self._total / self._step

    @property
    def duration(self) -> timedelta:
        return self._end - self._begin

    @property
    def duration_seconds(self) -> float:
        return self.duration.total_seconds()

    @property
    def is_emit(self) -> bool:
        if self._verbose < self._verbose_threshold:
            return False
        return self._step % self._logging_step == 0

    @property
    def begin(self) -> datetime:
        return deepcopy(self._begin)

    @begin.setter
    def begin(self, value: datetime) -> None:
        self._begin = value

    @property
    def end(self) -> datetime:
        return deepcopy(self._end)

    @end.setter
    def end(self, value: datetime) -> None:
        self._end = value

    @property
    def step(self) -> int:
        return self._step

    @step.setter
    def step(self, value: int) -> None:
        self._step = value

    def add_step(self, value=1) -> None:
        self._step += value

    def clear(self) -> None:
        self._step = 0
        self._begin = datetime.now()
        self._end = datetime.now()
        self._total = 0.0

    def get_report(self) -> str:
        return self._strfmt.format(name=self.name, step=self._step, avg=self.avg)

    def do_logging(self) -> None:
        self._logger.log(self._level, self.get_report())

    def do_enter(self, begin: Optional[datetime] = None) -> None:
        self._step += 1
        self._begin = begin if begin else datetime.now()

    def do_exit(self, end: Optional[datetime] = None) -> None:
        self._end = end if end else datetime.now()
        self._total += self.duration_seconds

        if self.is_emit:
            self.do_logging()
            if self._clear_emitted:
                self.clear()

    def __enter__(self):
        self.do_enter()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.do_exit()
