import os
import kagglehub

DATA_DIR = "data"
DATASET_NAME = "lincolnzh/martianlunar-crater-detection-dataset"

def download_and_extract_dataset(dataset_name: str) -> str:
    return kagglehub.dataset_download(dataset_name)
    
def move(download_path: str, target_dir: str) -> None:
    os.makedirs(target_dir, exist_ok=True)
    for item in os.listdir(download_path):
        src = os.path.join(download_path, item)
        dst = os.path.join(target_dir, item)
        if os.path.isdir(src):
            os.rename(src, dst)
        else:
            os.replace(src, dst)

def main():
    path = download_and_extract_dataset(DATASET_NAME)
    move(path, DATA_DIR)
    print(f"Extracted and moved to: {DATA_DIR}")

if __name__ == "__main__":
    main()
