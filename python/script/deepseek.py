import asyncio
import json
from playwright.async_api import async_playwright

async def save_cookies():
    """首次运行：手动登录并保存Cookies + LocalStorage"""
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        context = await browser.new_context()
        page = await context.new_page()

        await page.goto("https://chat.deepseek.com", wait_until="networkidle")
        input("请手动登录后按回车继续...")  # 确保登录完成

        # 保存Cookies和LocalStorage
        cookies = await context.cookies()
        storage_state = await context.storage_state()  # 包含Cookies和LocalStorage

        with open("deepseek_cookies.json", "w") as f:
            json.dump(cookies, f)
        with open("deepseek_storage.json", "w") as f:
            json.dump(storage_state, f)
        
        await browser.close()
        print("登录状态已保存")

async def ask_question(question: str):
    """使用持久化状态提问"""
    async with async_playwright() as p:
        # 加载完整浏览器状态（Cookies + LocalStorage）
        try:
            with open("deepseek_storage.json", "r") as f:
                storage_state = json.load(f)
            browser = await p.chromium.launch(headless=False)
            context = await browser.new_context(storage_state=storage_state)
        except FileNotFoundError:
            print("未找到保存的登录状态，请先运行save_cookies()")
            return

        page = await context.new_page()
        await page.goto("https://chat.deepseek.com", wait_until="networkidle")

        # 检查登录状态（示例：检测用户头像等元素）
        try:
            await page.wait_for_selector(".user-avatar", timeout=5000)  # 登录成功后的元素
        except:
            print("登录状态已失效，请重新保存Cookies")
            await browser.close()
            return

        # 输入问题
        input_selector = "textarea[placeholder='输入你的问题...']"
        await page.fill(input_selector, question)
        await page.click("button:has-text('发送')")

        # 获取回答
        answer_selector = ".answer-text"  # 根据实际页面调整
        await page.wait_for_selector(answer_selector, timeout=30000)
        answer = await page.inner_text(answer_selector)

        print("\n问题:", question)
        print("回答:", answer.strip())
        await browser.close()

async def main():
    # 首次使用时取消注释下一行
    # await save_cookies()

    questions = [
        "Python如何发送HTTP请求？",
        "用requests库怎么写？"
    ]
    for q in questions:
        await ask_question(q)
        await asyncio.sleep(2)  # 避免请求过快

if __name__ == "__main__":
    asyncio.run(main())