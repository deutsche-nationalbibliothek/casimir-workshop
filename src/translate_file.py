# Example Usage:
# python src/translate_file.py \
#     --input data/gnd_pref-labels.csv \
#     --column label_text_ger \
#     --output data/gnd_pref-labels_w-translation.csv  \
#     --model mistralai/Ministral-8B-Instruct-2410

import argparse
import os
import pandas as pd
from vllm import LLM, SamplingParams




class Translator:
    def __init__(self, model_name, system_prompt=None, tensor_parallel_size=1, gpu_ids=None):
        hf_token = os.getenv("HF_TOKEN")
        if not hf_token:
            raise EnvironmentError("HF_TOKEN environment variable not set.")
        llm_kwargs = {
            "model": model_name,
            "hf_token": hf_token,
            "tensor_parallel_size": tensor_parallel_size,
            "gpu_memory_utilization": 0.8
        }
        if gpu_ids is not None:
            llm_kwargs["device"] = gpu_ids
        self.llm = LLM(**llm_kwargs)
        self.sampling_params = SamplingParams(
            temperature=0.7, max_tokens=128,
            stop=["<|user|>", "OUTPUT:"]
        )
        self.system_prompt = system_prompt

    def translate(self, texts):
        # Use chat template: system prompt as system message, text as user message
        prompts = []
        for text in texts:
            if self.system_prompt:
                prompt = f"<|system|>\n{self.system_prompt}\n<|user|>INPUT: \n{text}\n<|assistant|>OUTPUT:\n"
            else:
              prompt = text
            prompts.append(prompt)
        results = self.llm.generate(prompts, self.sampling_params)
        return [r.outputs[0].text for r in results]

def run():
    parser = argparse.ArgumentParser(description="Translate a column in a CSV file using an LLM.")
    parser.add_argument("--input", required=True, help="Path to input CSV file")
    parser.add_argument("--column", required=True, help="Column name to translate")
    parser.add_argument("--model", required=True, help="Huggingface model name")
    parser.add_argument("--output", required=True, help="Path to output CSV file")
    args = parser.parse_args()

    print("Reading input file...")
    df = pd.read_csv(args.input)
    if args.column not in df.columns:
        raise ValueError(f"Column '{args.column}' not found in input file.")
    texts = df[args.column].astype(str).tolist()

    system_prompt = "Translate the following German text to English. Output only" \
    " the translation, without repeating the input, comments, or explanations. " \
    "If the input is already in English, output it unchanged." 
    print("Loading model...")
    translator = Translator(args.model, system_prompt=system_prompt)
    print("Translating texts...")
    translations = translator.translate(texts)
    output_column = args.column.replace("_ger", "_eng")
    df[output_column] = translations
    df.to_csv(args.output, index=False)

if __name__ == "__main__":
    run()