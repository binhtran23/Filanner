from app.core.config import settings


def calculate_check_in_points(streak_count: int) -> int:
    base_points = settings.POINTS_PER_CHECK_IN
    streak_bonus = (streak_count // 5) * settings.STREAK_BONUS_POINTS
    return base_points + streak_bonus


def get_asset_url_for_day(day: int) -> str:
    asset_day = ((day - 1) % 30) + 1
    return f"https://cdn.filanner.com/assets/3d/day-{asset_day}.glb"
