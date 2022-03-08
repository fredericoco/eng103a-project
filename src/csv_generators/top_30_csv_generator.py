import csv
import os
from io import StringIO

class Top30CSVGenerator:

    def generate_top_30_csv(self, top_30_array, csv_file_location=os.path.expanduser('~/Downloads/'), file_name='ItJobsWatchTop30.csv', headers_array=None):
        with open(csv_file_location + file_name, 'w+', newline="") as top30csv:
            writer = csv.writer(top30csv)
            if headers_array is not None:
                writer.writerow(headers_array)
            writer.writerows(top_30_array)

# class Top30CSVGeneratorString:

#     def generate_top_30_csv(self, top_30_array, csv_file_location=os.path.expanduser('~/Downloads/'), file_name='ItJobsWatchTop30.csv', headers_array=None):
#         with open(csv_file_location + file_name, 'w+', newline="") as top30csv:
#             writer = csv.writer(top30csv)
#             if headers_array is not None:
#                 writer.writerow(headers_array)
#             writer.writerows(top_30_array)
#         new_csvfile = StringIO.StringIO()
#         wr = csv.writer(new_csvfile, )

if __name__ == '__main__':
    print()
