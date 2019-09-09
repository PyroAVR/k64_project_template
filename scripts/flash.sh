openocd -f ../frdm-kl64f.cfg -c "init;kinetis mdm mass_erase 0;reset halt;flash write_image build/main.bin 0 bin;reset run; exit"

