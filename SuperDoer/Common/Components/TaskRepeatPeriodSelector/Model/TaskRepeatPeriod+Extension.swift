extension TaskRepeatPeriod {
    var detailTitle: String {
        switch (self.amount, self.unit) {
        case (1, .day): "Каждый день"
        case (_, .day): "Раз в \(self.amount) дн."
        case (1, .week): "Каждую неделю"
        case (_, .week): "Раз в \(self.amount) нед."
        case (1, .month): "Каждый месяц"
        case (_, .month): "Раз в \(self.amount) мес."
        case (1, .year): "Каждый год"
        case (_, .year): "Каждые \(self.amount) г"
        }
    }
}
