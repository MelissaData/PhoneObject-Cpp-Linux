# Melissa Phone Object Linux C++

CXX = g++
CXXFLAGS = -Wall -Wextra -pedantic -std=c++11 -g
LDLIBS = -lmdPhone
LDFLAGS = -L/mnt/f/TEST/linux/PhoneObject-Cpp-Linux/MelissaPhoneObjectLinuxCpp/Build
RM = rm -f

OUT_DIR = Build

MelissaPhoneObjectLinuxCpp: Main.cpp PhoneObject.cpp mdPhone.h mdEnums.h | $(OUT_DIR)
	$(CXX) $(CXXFLAGS) Main.cpp PhoneObject.cpp $(LDFLAGS) $(LDLIBS) -o $(OUT_DIR)/$@

clean:
	$(RM) *.o $(OUT_DIR)/MelissaPhoneObjectLinuxCpp

