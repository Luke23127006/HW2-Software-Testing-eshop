# AI Critique

*(Write a single paragraph of 200-300 words addressing all three questions below)*

**1. Where did the AI get something wrong, biased, or incomplete?**
During the test design process, the AI did a great job but still missed some important details. For example, in feature FR-03 (Forgot Password), the AI forgot to include test cases for global security rules (SEC-07), such as the OTP expiration time. For feature FR-16 (CSV Import), the AI designed very good test cases for "name" and "price", but it completely missed security tests like XSS injection (SEC-04) and failed to test other important header fields like the category_id foreign key.

**2. Why did it fail to catch the issue?**
The AI failed to catch these issues because of "tunnel vision." When I asked the AI to analyze a specific feature, it only focused on the text block of that feature. It did not automatically cross-reference the global security requirements table or the overall system rules in the README file. The AI acts like a machine following the exact steps in my prompt; it cannot see the "big picture" of the whole project unless I clearly tell it to look at other sections.

**3. What principle have you learned about collaborating with AI during this assignment?**
The most important principle I learned is that AI is a helpful assistant, not an independent expert. We cannot trust AI 100%. To get the best results, I must always use a "Cross-check" process. This means I need to review the AI's output carefully or use another AI (like Gemini Web acting as a QA Manager) to double-check the first AI's work. A good tester must always review the AI's test plan against the full system requirements to catch missing gaps and prevent AI hallucinations.