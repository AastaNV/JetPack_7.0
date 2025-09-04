import openai
import numpy as np
import io
import base64
from PIL import Image
import time


max_tokens = 50
url = "http://0.0.0.0:11434/v1"
model = "gemma3:12b-it-qat"
num_images = 8


# Local OpenAI-compatible server config
client = openai.OpenAI(
    base_url=url,
    api_key="not-needed"
)

def generate_base64_images(num_images=1, size=(336, 336)):
    """Generate random test images"""
    encoded_images = []
    for _ in range(num_images):
        array = (np.random.rand(*size, 3) * 255).astype(np.uint8)
        image = Image.fromarray(array)

        buffer = io.BytesIO()
        image.save(buffer, format="JPEG")
        b64_image = base64.b64encode(buffer.getvalue()).decode("utf-8")
        encoded_images.append(b64_image)
    return encoded_images

def main():

    print(client.models.list())

    b64_images = generate_base64_images(num_images=num_images)

    messages = [{"role": "user", "content": [
        {"type": "text", "text": "Describe what you see in the images. "}
    ]}]

    for b64 in b64_images:
        messages[0]["content"].append({
            "type": "image_url",
            "image_url": {
                "url": f"data:image/jpeg;base64,{b64}"
            }
        })

    # Time the request
    start_time = time.time()
    response = client.chat.completions.create(
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
