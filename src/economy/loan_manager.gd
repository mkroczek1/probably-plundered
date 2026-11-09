class_name LoanManager
extends RefCounted

const STARTING_DEBT: int = 500000
const MAX_DAYS: int = 45

const INSTALLMENTS = {
	7: 15000,
	14: 25000,
	21: 40000,
	28: 60000,
	35: 90000,
	42: 130000,
	45: 500000
}

static func get_daily_overhead(day: int, workshop_upgrades: int = 0) -> int:
	return 50 + (day * 3) + (workshop_upgrades * 20)

static func get_installment_due(day: int) -> int:
	return INSTALLMENTS.get(day, 0)

static func is_installment_day(day: int) -> bool:
	return day in INSTALLMENTS

static func get_next_installment_day(day: int) -> int:
	var days = [7, 14, 21, 28, 35, 42, 45]
	for d in days:
		if d >= day:
			return d
	return 45

static func get_next_installment_amount(day: int) -> int:
	var next_day = get_next_installment_day(day)
	return INSTALLMENTS.get(next_day, 0)
