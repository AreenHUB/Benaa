def calculate_structural_logic(element_type, count, length, width, height):
    # هنا ستضع معادلاتك الهندسية المعقدة التي كتبناها سابقاً
    volume = length * width * height * count
    concrete = volume * 1.05
    steel = (volume * 150) / 1000  # نسبة حديد افتراضية
    return {
        "concrete_m3": round(concrete, 2),
        "steel_tons": round(steel, 2),
        "total_cost": round((concrete * 300) + (steel * 2500), 2),
    }


def calculate_block_logic(length: float, height: float):
    # مساحة المتر المربع للجدار
    wall_area = length * height
    # حساب تقريبي للطابوق (بافتراض 12.5 طوبة للمتر المربع)
    blocks_count = wall_area * 12.5 * 1.05  # 5% waste
    cement = blocks_count * 0.02
    sand = blocks_count * 0.006

    return {
        "blocks": round(blocks_count),
        "cement_bags": round(cement, 2),
        "sand_m3": round(sand, 2),
    }
