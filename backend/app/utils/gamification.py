from app.core.config import settings


def calculate_check_in_points(streak_count: int) -> int:
    """
    Calculate points awarded for check-in based on streak.
    
    Base points: POINTS_PER_CHECK_IN
    Bonus: STREAK_BONUS_POINTS for every 5-day streak
    """
    base_points = settings.POINTS_PER_CHECK_IN
    
    # Bonus for every 5 days
    streak_bonus = (streak_count // 5) * settings.STREAK_BONUS_POINTS
    
    return base_points + streak_bonus


def get_asset_url_for_day(day: int) -> str:
    """
    Get 3D asset URL based on check-in day.
    
    For hackathon demo: Return placeholder URLs.
    In production: Map to actual 3D model URLs hosted on CDN.
    """
    # Cycle through 30 different assets (repeat after 30 days)
    asset_day = ((day - 1) % 30) + 1
    
    # Return demo URL (replace with actual CDN URLs)
    return f"https://cdn.filanner.com/assets/3d/day-{asset_day}.glb"


def get_asset_description(day: int) -> str:
    """Get description for the 3D asset."""
    descriptions = {
        1: "Cây mầm xanh - Bắt đầu hành trình",
        5: "Cây non phát triển",
        10: "Cây đã có nhiều lá",
        15: "Cây lớn có hoa",
        20: "Cây trổ bông",
        30: "Cây trái chín - Hoàn thành 1 tháng!",
    }
    
    # Get closest milestone
    for milestone in sorted(descriptions.keys(), reverse=True):
        if day >= milestone:
            return descriptions[milestone]
    
    return "Tiếp tục phát triển cây của bạn!"
