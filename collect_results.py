from datetime import datetime
import io
import os
import pandas as pd
import argparse


def convert_time_to_seconds(time_str):
    if isinstance(time_str, str):
        try:
            minutes, seconds = time_str.split(':')
            seconds, milliseconds = seconds.split('.')
            return int(minutes) * 60 + int(seconds) + float(milliseconds) / 1000
        except ValueError:
            pass
    return ''


def parse_csv(csv_path):
    df = pd.read_csv(csv_path, sep='|', header=None, skipinitialspace=True)
    df = df.replace(' ', '0')
    df.dropna(inplace=True, how="all")
    df = df.drop(df.columns[0], axis=1)  # Drop first column
    df = df.drop(df.columns[-1], axis=1)  # Drop last column
    return df


def process_dataset(dataset_dir):
    dirs = os.listdir(dataset_dir)
    if 'results' in dirs:
        result_dir = os.path.join(dataset_dir, 'results')
        for result_root, result_dirs, result_files in os.walk(result_dir):
            df_list = []
            csv_buf = io.StringIO()
            for test_result_dir in result_dirs:
                if 'comp_stats.csv' in os.listdir(os.path.join(result_root, test_result_dir)):
                    csv_path = os.path.join(result_root, test_result_dir, 'comp_stats.csv')
                    df = parse_csv(csv_path)
                    df.columns = [test_result_dir, 'min', 'max', 'mean', 'std dev', 'valid percent', 'processing time']
                    df['processing time'] = df['processing time'].apply(convert_time_to_seconds)
                    df_list.append(df.reset_index(drop=True))
            if len(df_list) > 0:
                for df in df_list:
                    buf = io.StringIO()
                    df.to_csv(buf, index=False, sep='|')
                    csv_buf.write(buf.getvalue())
                    csv_buf.write("||||||\n")
                    csv_buf.write("||||||\n")
                    csv_buf.write("||||||\n")
                now = datetime.now()
                timestamp = now.strftime('%Y_%m_%d')
                result_loc = os.path.basename(os.path.dirname(result_root))
                result_file = os.path.join(result_root, result_loc + "_" + "benchmark_" + timestamp + ".csv")
                with open(result_file, 'w') as f:
                    f.write(csv_buf.getvalue())
                    print("{} written".format(result_file))


def main():
    parser = argparse.ArgumentParser(description='Parse CSV files in datasets')
    parser.add_argument('datasets_dir', type=str, help='Path to datasets directory')
    args = parser.parse_args()

    for dataset_name in os.listdir(args.datasets_dir):
        dataset_dir = os.path.join(args.datasets_dir, dataset_name)
        if os.path.isdir(dataset_dir):
            process_dataset(dataset_dir)


if __name__ == '__main__':
    main()
