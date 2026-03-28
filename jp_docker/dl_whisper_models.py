from faster_whisper.utils import download_model
import os
import argparse

def main():
    # Create the parser and add a description
    parser = argparse.ArgumentParser(description="Whisper model downloader.")

    parser.add_argument('--model_dir', type=str, default='./whisper_models', help="Directory to store model")
    parser.add_argument('--model', type=str, default='turbo', help="Model to download.")

    args = parser.parse_args()
    model_dir = args.model_dir
    model = args.model

    print(f'Saving to directory: {model_dir}')
    
    if not os.path.exists(model_dir):
        os.makedirs(model_dir)

    # Download the model files to the specified directory
    model_path = download_model(model, output_dir=model_dir)
    print(f"Downloaded model: '{model}'")

if __name__ == "__main__":
    main()
