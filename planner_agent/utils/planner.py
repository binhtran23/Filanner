# To run this code you need to install the following dependencies:
# pip install google-genai

import base64
import os
from google import genai
from google.genai import types
import json
import asyncio

# Đọc file markdown system instruction
with open("assets/SYSTEM_INSTRUCTION.md", "r", encoding="utf-8") as f:
    SYSTEM_INSTRUCTION = f.read()

def generate_financial_prompt(user_data):
    """
    Hàm nhận dict dữ liệu từ API và trả về chuỗi Context Prompt.
    """
    
    # 1. Helper function để format tiền tệ (VD: 100000 -> "100.000")
    def format_money(amount):
        if amount is None: return "0"
        return "{:,.0f}".format(amount).replace(",", ".")

    # 2. Xử lý danh sách chi tiêu bắt buộc
    # Chuyển list object thành chuỗi gạch đầu dòng dễ đọc
    expense_lines = []
    if user_data.get("chi_tieu_bat_buoc"):
        for item in user_data["chi_tieu_bat_buoc"]:
            line = (
                f"    - {item['ten_chi_tieu']}: {format_money(item['uoc_tinh'])} VNĐ "
                f"({item['tan_suat']}) | Note: {item['note']}"
            )
            expense_lines.append(line)
    
    expenses_str = "\n".join(expense_lines) if expense_lines else "    - Không có dữ liệu chi tiêu"

    # 3. Xử lý logic hiển thị Nợ và Mục tiêu (nếu null)
    if user_data.get("no"):
        debt_status = f"Đang có nợ (Tổng: {format_money(user_data.get('tong_no'))} VNĐ)"
    else:
        debt_status = "Không có nợ"

    # Nếu mục tiêu là None hoặc rỗng, thay bằng câu nhắc mặc định cho Agent
    goal = user_data.get("muc_tieu")
    if not goal:
        goal = "Chưa có mục tiêu cụ thể. (yêu cầu agent tối ưu chi tiêu để người dùng tiết kiệm hoặc gợi ý mục tiêu khả thi như tạo quỹ dự phòng khẩn cấp)."

    # 4. Ghép vào Template (Sử dụng f-string)
    prompt_template = f"""
Hồ sơ khách hàng
1. THÔNG TIN CÁ NHÂN
- Tuổi: {user_data.get('tuoi_tac')}
- Nghề nghiệp: {user_data.get('nghe_nghiep')}
- Tình trạng hôn nhân: {user_data.get('tinh_trang_hon_nhan')}

2. SỨC KHỎE TÀI CHÍNH
- Thu nhập hàng tháng: {format_money(user_data.get('thu_nhap_hang_thang'))} VNĐ
- Tình trạng nợ: {debt_status}
- Chi tiêu phát sinh thêm: {format_money(user_data.get('chi_tieu_phat_sinh'))} VNĐ

3. CHI TIẾT CHI TIÊU BẮT BUỘC (Fixed Costs)
{expenses_str}

4. MỤC TIÊU TÀI CHÍNH
- {goal}
"""
    return prompt_template.strip()

async def generate():
    client = genai.Client(
        api_key=os.getenv("GEMINI_API_KEY"),
    )

    model = "gemini-flash-latest"

    # read mock data json file
    with open("mockData/khongNo_coAim.json", "r", encoding="utf-8") as f:
        user_data = json.load(f)
    contents = [
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text=generate_financial_prompt(user_data)),
            ],
        ),
    ]
    tools = [
        types.Tool(googleSearch=types.GoogleSearch(
        )),
    ]
    generate_content_config = types.GenerateContentConfig(
        temperature=0.5,
        thinking_config=types.ThinkingConfig(
            thinking_budget=-1,
        ),
        media_resolution="MEDIA_RESOLUTION_MEDIUM",
        tools=tools,
        system_instruction=[
            types.Part.from_text(text=SYSTEM_INSTRUCTION),
        ],
    )

    full_response_text = ""
    try:
        async for chunk in client.models.generate_content_stream(
            model=model,
            contents=contents,
            config=generate_content_config,
        ):
        if chunk.text:
            print(chunk.text, end="")
            full_response_text += chunk.text
        return full_response_text
    except Exception as e:
        print(f"Error during generation: {e}")
