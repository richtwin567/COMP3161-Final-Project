# For testing the time of the scripts

# Keeping this in just in case anyone would like to test any others
from faker import Faker
import time

fake_obj = Faker()


def create_fake_lst():
    lst = []
    for value in range(50000):
        lst.append(fake_obj.paragraph())
    return lst


lst_multi_time1 = time.time()
lst = [fake_obj.paragraph()] * 50000
lst_multi_time2 = time.time()

total = lst_multi_time2 - lst_multi_time1
print(total)

iter_time1 = time.time()
test = create_fake_lst()
iter_time2 = time.time()

new_total = iter_time2 - iter_time1
print(new_total)

print(new_total/total)
