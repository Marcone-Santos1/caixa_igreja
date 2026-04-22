/// Início do dia local (00:00).
DateTime startOfLocalDay(DateTime d) =>
    DateTime(d.year, d.month, d.day);

/// Fim do dia local (23:59:59.999).
DateTime endOfLocalDay(DateTime d) =>
    DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

int startOfLocalDayMs(DateTime d) =>
    startOfLocalDay(d).millisecondsSinceEpoch;

int endOfLocalDayMs(DateTime d) =>
    endOfLocalDay(d).millisecondsSinceEpoch;
