import asyncio
import json
from playwright.async_api import async_playwright

async def save_session():
    """首次运行：手动登录并保存会话状态"""
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        context = await browser.new_context()
        page = await context.new_page()

        # 访问DeepSeek并等待页面完全加载
        await page.goto("https://chat.deepseek.com", wait_until="networkidle")
        input("请手动登录后按回车继续...")

        # 保存完整的会话状态（Cookies + LocalStorage）
        storage_state = await context.storage_state()
        with open("deepseek_session.json", "w") as f:
            json.dump(storage_state, f)
        
        await browser.close()
        print("会话状态已保存到 deepseek_session.json")

async def get_answer_html(question: str):
    """发送问题并返回回答的HTML代码"""
    async with async_playwright() as p:
        # 加载会话状态
        try:
            with open("deepseek_session.json", "r") as f:
                storage_state = json.load(f)
            browser = await p.chromium.launch(headless=False)
            context = await browser.new_context(storage_state=storage_state)
        except FileNotFoundError:
            print("错误：未找到会话文件，请先运行 save_session()")
            return None

        page = await context.new_page()
        
        # 导航到DeepSeek并检查登录状态
        await page.goto("https://chat.deepseek.com", wait_until="networkidle")
        if await page.query_selector(".login-form"):  # 如果看到登录表单
            print("登录状态已失效，请重新保存会话")
            await browser.close()
            return None

        # 输入问题（使用您提供的选择器）
        input_selector = "textarea#chat-input"
        await page.fill(input_selector, question)
        await page.click("button:has-text('发送')")

        # 等待回答生成（使用您提供的HTML输出选择器）
        output_selector = "div.ds-markdown.ds-markdown--block"
        await page.wait_for_selector(output_selector, state="attached", timeout=30000)
        
        # 获取回答的完整HTML代码
        answer_html = await page.inner_html(output_selector)
        
        await browser.close()
        return answer_html

async def main():
    # 首次使用时取消下一行注释
    # await save_session()

    questions = [
        "Python如何发送HTTP请求？"
    ]

    for q in questions:
        html = await get_answer_html(q)
        if html:
            print(f"\n问题：{q}")
            print("回答HTML：\n", html)
        await asyncio.sleep(2)  # 避免请求过快

if __name__ == "__main__":
    asyncio.run(main())