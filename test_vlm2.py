import time
from openai import OpenAI
import base64
import sys

def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")

client = OpenAI(
    api_key="EMPTY",
    base_url="http://localhost:8001/v1",
    timeout=3600
)

in_file = sys.argv[1]

base64_image = encode_image(in_file)
#print(f"image {base64_image}")

#from https://github.com/nvidia-cosmos/cosmos-reason2/blob/main/prompts/README.md
object_name = 'pen'
prompt1 = 'Caption the video in detail.'
prompt2 = 'Please caption the notable attributes in the provided image. List and describe all marked subjects in the image with their categories and detailed captions using a json with keyword "subject_id", "category" and "caption".'
prompt3 = f'Locate the bounding box of {object_name}. Return a json of this format {{"bb_2d": [x, y], "label": object label}}.'
prompt4 = 'What can be the next immediate action?'
prompt5 = 'You are given the task "{Place object on the desk}". Specify the 2D trajectory your end effector should follow in pixel space. Return the trajectory coordinates in JSON format like this: {"point_2d": [x, y], "label": "gripper trajectory"}.'
prompt6 = 'Please caption the notable attributes in the provided image. List and describe all marked subjects in the image with their categories, detailed captions, and bounding boxes using a json with keyword "subject_id", "category", "caption", and "bounding box".'
prompt7 = 'What are the coordinates of the clock in the image?'
prompt8 = 'What are the coordinates of the picture of the childs face in the image?'

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/jpeg;base64,{base64_image}",
                }
            },
            {
                "type": "text",
                "text": f"{prompt8}"
            }
        ]
    }
]

start = time.time()
response = client.chat.completions.create(
    model="Nvidia/Cosmos-Reason2-2B",
    messages=messages,
    max_tokens=2048
)
print(f"Response costs: {time.time() - start:.2f}s")
print(f"Generated text: {response.choices[0].message.content}")