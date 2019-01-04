/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/FiveStage.als   test_sb  >FiveStage.out

/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdown.als   test_flush_reload  >SpectreMeltdown_flush_reload.out
/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdown.als   test_meltdown  >SpectreMeltdown_test_meltdown.out
/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdown.als   test_spectre  >SpectreMeltdown_test_spectre.out

/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -Xms1024m -Xmx2048m -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdownCoh.als   test_flush_reload  >SpectreMeltdownCoh_flush_reload.out
/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdownCoh.als   test_meltdown  >SpectreMeltdownCoh_test_meltdown.out
/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdownCoh.als   test_spectre   >SpectreMeltdownCoh_test_spectre.out
/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdownCoh.als   test_prime_probe  >SpectreMeltdownCoh_prime_probe.out
/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdownCoh.als   test_meltdown_prime  >SpectreMeltdownCoh_test_meltdown.out
/yiyuan/data/wlm/java6/jdk1.6.0_45/bin/java -cp ./bin/:./bin/alloy4.2.jar MainClass   -f  ./bin/uarches/SpectreMeltdownCoh.als   test_spectre_prime   >SpectreMeltdownCoh_test_spectre.out

#python  ./out/production/checkmate/util/release-generate-graphs.py -i test.out -o test -c checkmate
#python  ./out/production/checkmate/util/release-symmetry-reduction.py -i ./graphs/
#python ./out/production/checkmate/util/release-generate-images.py -i ./graphs/ -o ./graphs_out

