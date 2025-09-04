from mlc_llm import MLCEngine
import time

max_tokens = 500
model  = "models/mlc/Qwen3-30B-A3B-Instruct-2507-q4bf16_1"
engine = MLCEngine(model)


def main():

    messages = [{"role": "user", "content": [
        {"type": "text", "text": "Can you write a short story?"}
    ]}]


    # Time the request
    start_time = time.time()
    response = engine.chat.completions.create(
        model=model,
        messages=messages,
        max_tokens=max_tokens
    )
    end_time = time.time()

    elapsed = end_time - start_time
    completion_tokens = response.usage.completion_tokens if response.usage else 0
    tps = completion_tokens / elapsed if elapsed > 0 else 0

    print(f"\nResponse:\n{response.choices[0].message.content}")
    print(f"\nElapsed time: {elapsed:.2f} sec")
    print(f"Completion tokens: {completion_tokens}")
    print(f"Approx. tokens/sec: {tps:.2f}")


if __name__ == "__main__":
    main()
    engine.terminate()
