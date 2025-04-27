import asyncio
import json
from playwright.async_api import async_playwright

async def save_session():
    """首次运行：保存登录状态"""
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        context = await browser.new_context()
        page = await context.new_page()

        await page.goto("https://chat.deepseek.com", wait_until="networkidle")
        input("请手动登录后按回车继续...")

        storage_state = await context.storage_state()
        with open("deepseek_session.json", "w") as f:
            json.dump(storage_state, f)
        
        await browser.close()
        print("会话状态已保存")

async def send_question(page, question: str):
    """通过键盘输入+回车提交问题"""
    input_selector = "textarea#chat-input"
    
    await page.click(input_selector)
    await page.fill(input_selector, "")
    await page.type(input_selector, question, delay=100)
    await asyncio.sleep(0.5)
    await page.keyboard.press("Enter")
    print("已通过回车键提交问题")

async def wait_for_answer(page):
    """等待回答生成的完整HTML"""
    answer_selector = "div.ds-markdown.ds-markdown--block"
    
    try:
        # 等待回答区域出现
        await page.wait_for_selector(answer_selector, state="attached", timeout=60000)
        
        # 确保内容已加载（检测子元素）
        await page.wait_for_selector(f"{answer_selector} > *", timeout=30000)
        
        # 返回完整的HTML内容
        return await page.inner_html(answer_selector)
    except Exception as e:
        print(f"等待回答超时：{str(e)}")
        return None

async def get_answer_html(question: str):
    async with async_playwright() as p:
        try:
            with open("deepseek_session.json", "r") as f:
                storage_state = json.load(f)
            browser = await p.chromium.launch(headless=False)
            context = await browser.new_context(storage_state=storage_state)
            page = await context.new_page()
            
            await page.goto("https://chat.deepseek.com", wait_until="networkidle")

            # 检查登录状态
            if await page.query_selector(".login-form"):
                print("登录失效，请重新保存会话")
                await browser.close()
                return None

            await send_question(page, question)
            return await wait_for_answer(page)
            
        except FileNotFoundError:
            print("错误：请先运行 save_session()")
            return None
        finally:
            await browser.close()

async def main():
    questions = [
        "使用python写一个冒泡排序",
        "请解释这个代码的工作原理"
    ]

    for q in questions:
        print(f"\n提交问题：{q}")
        html = await get_answer_html(q)
        if html:
            print("获取回答成功：")
            print(html)  # 打印完整HTML
        await asyncio.sleep(3)

if __name__ == "__main__":
    asyncio.run(main())