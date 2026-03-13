import 'package:flutter/material.dart';

class Barre extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Barre();
  }
}

class _Barre extends State<Barre> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(10, (index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 3,
              color: Colors.green,
            ),
            Expanded(
              flex: 1,
              child: ListTile(
                leading: Icon(Icons.paragliding),
                title: Text("Truc"),
              ),
            )
          ],
        );
      }),
    );
  }
}

/*
LISTE DES ANTENNES DU SERNIE ET LEURS CODES
		
1. PROVINCE EDUCATIONNELLE KINSHASA MONT-AMBA (11)
N°	Nom Antenne	Code Antenne
1	Antenne de LIMETE 1	1101
2	Antenne de LIMETE 2	1102
3	Antenne de MATETE 1	1103
4	Antenne de KISENSO 1	1104
5	Antenne de LEMBA 1	1105
6	Antenne de NGABA	1106
7	Antenne de LIMETE 3	1107
8	Antenne de MATETE 2	1108
9	Antenne de KISENSO 2	1109
10	Antenne de LEMBA 2	1110
		
2. PROVINCE EDUCATIONNELLE KINSHASA FUNA (12)
N°	Nom Antenne	Code Antenne
1	Antenne de KASA-VUBU	1201
2	Antenne de KALAMU 1	1202
3	Antenne de NGIRI-NGIRI 1	1203
4	Antenne de BANDALUNGWA	1204
5	Antenne de BUMBU 1	1205
6	Antenne de SELEMBAO 1	1206
7	Antenne de SELEMBAO 2	1207
8	Antenne de MAKALA	1208
9	Antenne de KALAMU 2	1209
10	Antenne de NGIRI-NGIRI 2	1210
11	Antenne de BUMBU 2	1211
12	Antenne de SELEMBAO 3	1212
		
3. PROVINCE EDUCATIONNELLE KINSHASA LUKUNGA (13)
N°	Nom Antenne	Code Antenne
1	Antenne de GOMBE	1301
2	Antenne de KINTAMBO	1302
3	Antenne de NGALIEMA 1	1303
4	Antenne de NGALIEMA 2	1304
5	Antenne de NGALIEMA 3	1305
6	Antenne de MONT-NGAFULA 1	1306
7	Antenne de MONT-NGAFULA 2	1307
8	Antenne de KINSHASA	1308
9	Antenne de BARUMBU 1	1309
10	Antenne de LINGWALA	1310
11	Antenne de NGALIEMA 4	1311
12	Antenne de MONT-NGAFULA 3	1312
13	Antenne de BARUMBU 2	1313
		
4. PROVINCE EDUCATIONNELLE KINSHASA TSHANGU (14)
N°	Nom Antenne	Code Antenne
1	Antenne de NDJILI 1	1401
2	Antenne de KIMBANSEKE 1	1405
3	Antenne de KIMBANSEKE 2	1406
4	Antenne de KIMBANSEKE 3	1407
5	Antenne de MASINA 1	1408
6	Antenne de MASINA 2	1409
7	Antenne de KIMBANSEKE 4	1412
8	Antenne de KIMBANSEKE 5	1413
9	Antenne de MASINA 3	1414
10	Antenne de NDJILI 2	1410
		
5. PROVINCE EDUCATIONNELLE KINSHASA PLATEAU (15)
N°	Nom Antenne	Code Antenne
1	Antenne de NSELE 1	1501
2	Antenne de NSELE 2	1502
3	Antenne de NSELE 3	1503
4	Antenne de NSELE 4	1504
5	Antenne de MALUKU 1	1505
6	Antenne de MALUKU 2	1506
7	Antenne de MALUKU 3	1507
8	Antenne de MALUKU 4	1508
		
6. PROVINCE EDUCATIONNELLE KONGO CENTRAL 1 (21)
N°	Nom Antenne	Code Antenne
1	Antenne de MATADI 1	2101
2	Antenne de MATADI 2	2102
3	Antenne de BOMA	2103
4	Antenne de LUKULA 1	2104
5	Antenne de TSHELA 1	2105
6	Antenne de SEKE-BANZA 1	2106
7	Antenne de MUANDA 1	2107
8	Antenne de LUKULA 2	2108
9	Antenne de TSHELA 2	2109
10	Antenne de SEKE-BANZA 2	2110
11	Antenne de MUANDA 2	2111
		








7. PROVINCE EDUCATIONNELLE KONGO CENTRAL 2 (22)
N°	Nom Antenne	Code Antenne
1	Antenne de MBANZA-NGUNGU 1	2201
2	Antenne de MBANZA-NGUNGU 2	2202
3	Antenne de SONGOLOLO 1	2203
4	Antenne de LUOZI 1	2204
5	Antenne de LUOZI 2	2205
6	Antenne de SONGOLOLO 2	2206
		
8. PROVINCE EDUCATIONNELLE KONGO CENTRAL 3 (23)
N°	Nom Antenne	Code Antenne
1	Antenne de MADIMBA 1	2301
2	Antenne de MADIMBA 2	2302
3	Antenne de KIMVULA	2303
4	Antenne de KASANGULU	2304
		
9. PROVINCE EDUCATIONNELLE MAI-NDOMBE 1 (31)
N°	Nom Antenne	Code Antenne
1	Antenne d'INONGO 1	3101
2	Antenne de BERENGE	3102
3	Antenne d'INONGO 2	3103
4	Antenne d'INONGO 3	3104
5	Antenne d'INONGO 4	3105
6	Antenne d'INONGO 5	3106
7	Antenne de KIRI	3107
8	Antenne de MPENDWA	3108
		
10. PROVINCE EDUCATIONNELLE MAI-NDOMBE 2 (37)
N°	Nom Antenne	Code Antenne
1	Antenne de BOLOBO	3701
2	Antenne de MUSHIE 1/MUSHIE	3702
3	Antenne de MUSHIE 2/MBALI	3703
4	Antenne de KWAMOUTH	3704
		
11. PROVINCE EDUCATIONNELLE MAI-NDOMBE 3 (38)
N°	Nom Antenne	Code Antenne
1	Antenne de KUTU 1/NIOKI	3801
2	Antenne de KUTU 2/SEMENDUA	3802
3	Antenne de KUTU 3/BOSOBE	3803
4	Antenne de KUTU 4/CITE DE KUTU	3804
5	Antenne de KUTU 5/TOLO	3805
6	Antenne de KUTU 6/BOKORO	3806
7	Antenne d’OSHWE 1/CITE D'OSHWE	3807
8	Antenne d’OSHWE 2/BENABENDI	3808
9	Antenne d’OSHWE 3/LOKOLAMA	3809
10	Antenne d’OSHWE 4/NKAW	3810
		
12. PROVINCE EDUCATIONNELLE KWILU 1 (32)
N°	Nom Antenne	Code Antenne
1	Antenne de BANDUNDU VILLE 1	3201
2	Antenne de BAGATA 1	3202
3	Antenne de BAGATA 2/FATUNDU	3203
4	Antenne de BAGATA 3/MPO	3204
5	Antenne de BAGATA 4/MANZASAY	3205
6	Antenne de BULUNGU 3/DJUMA	3206
7	Antenne de BANDUNDU VILLE 2	3207
		
13. PROVINCE EDUCATIONNELLE KWILU 2 (34)
N°	Nom Antenne	Code Antenne
1	Antenne de KIKWIT 1	3401
2	Antenne de KIKWIT 2	3402
3	Antenne de KIKWIT 3	3403
4	Antenne de KIKWIT 4	3404
5	Antenne de BULUNGU 1	3405
6	Antenne de BULUNGU 2	3406
7	Antenne de BULUNGU 4	3407
8	Antenne de MASIMANIMBA 1/CENTRE	3408
9	Antenne de MASIMANIMBA 2/PAY KONGILA	3409
10	Antenne de MASIMANIMBA 3/LETA	3410
11	Antenne de MASIMANIMBA 4/MOSANGO	3411
12	Antenne de BULUNGU 6	3412
13	Antenne de BULUNGU 5	3413
14	Antenne de BULUNGU 7	3414
15	Antenne de BULUNGU 8	3415
16	Antenne de MOKAMO	3416
17	Antenne de KITOYI	3417
18	Antenne de MASAMUNA	3418
19	Antenne de MUTELO	3419
		
14. PROVINCE EDUCATIONNELLE KWILU 3 (35)
N°	Nom Antenne	Code Antenne
1	Antenne d'IDIOFA-CENTRE	3501
2	Antenne d’OBALA	3502
3	Antenne de MATEKO	3503
4	Antenne de KALO	3504
5	Antenne de MANGAI	3505
6	Antenne de KIPUKU	3506
7	Antenne de BANDA	3507
8	Antenne de GUNGU 1	3508
9	Antenne de GUNGU 2	3509
10	Antenne de GUNGU 3	3510
11	Antenne de GUNGU 4	3511
12	Antenne de GUNGU 5	3512
13	Antenne de GUNGU 6	3513
14	Antenne de DIBAYA-LUBWE	3514
15	Antenne de BULWEM	3515
		
15. PROVINCE EDUCATIONNELLE KWANGO 1 (33)
N°	Nom Antenne	Code Antenne
1	Antenne de KENGE 1	3301
2	Antenne de KENGE 2	3302
3	Antenne de FESHI 1	3303
4	Antenne de FESHI 2	3304
5	Antenne de LOBO	3305
6	Antenne de KOBO	3306
7	Antenne de KIMBAU	3309
8	Antenne de POPO KABAKA 1	3310
9	Antenne de POPO KABAKA 2	3311
10	Antenne de POPO KABAKA 3	3312
11	Antenne de POPO KABAKA 4	3313
12	Antenne de POPO KABAKA 5	3314
13	Antenne de PONT-KWANGO	3315
		
16. PROVINCE EDUCATIONNELLE KWANGO 2 (36)
N°	Nom Antenne	Code Antenne
1	Antenne de KASONGO-LUNDA 1	3601
2	Antenne de KASONGO-LUNDA 2	3602
3	Antenne de KAHEMBA 1	3603
4	Antenne de KAHEMBA 2	3604
5	Antenne de KAHEMBA 3	3605
6	Antenne de MAWANGA	3606
7	Antenne de PANZI	3607
8	Antenne de KASA	3608
9	Antenne de KINGWANGALA	3609
10	Antenne de KINGULU	3610
11	Antenne de SWA-TENDA	3611
12	Antenne de KIBUNDA	3612
		
17. PROVINCE EDUCATIONNELLE EQUATEUR 1 (41)
N°	Nom Antenne	Code Antenne
1	Antenne de MBANDAKA 1	4101
2	Antenne de MBANDAKA 2	4102
3	Antenne de BIKORO 1	4103
4	Antenne de BIKORO 2	4104
5	Antenne de BIKORO 3	4105
6	Antenne de LUKOLELA 1	4106
7	Antenne de BOMONGO 1	4107
8	Antenne de BOMONGO 2	4108
9	Antenne de BIKORO 4	4109
10	Antenne d'INGENDE 1	4110
11	Antenne d'INGENDE 2	4111
12	Antenne d'INGENDE 3	4112
13	Antenne de MBANDAKA 3	4113
14	Antenne de LUKOLELA 2	4114
15	Antenne de LUKOLELA 3	4115
16	Antenne de BOMONGO 3	4116
17	Antenne de MBANDAKA 4	4117
18	Antenne d'INGENDE 4	4118
19	Antenne de LUKOLELA 4	4119
		
18. PROVINCE EDUCATIONNELLE EQUATEUR 2 (56)
N°	Nom Antenne	Code Antenne
1	Antenne de BASANKUSU 1	4601
2	Antenne de BASANKUSU 2	4602
3	Antenne de BASANKUSU 3	4603
4	Antenne de BASANKUSU 4	4604
5	Antenne de BOLOMBA 1	4605
6	Antenne de BOLOMBA 2	4606
7	Antenne de BOLOMBA 3	4607
8	Antenne de BOLOMBA 4	4608
9	Antenne de BOLOMBA 5	4609
10	Antenne de BOLOMBA 6	4610
11	Antenne de MAKANZA 1	4611
12	Antenne de MAKANZA 2	4612
13	Antenne de MAKANZA 3	4613
14	Antenne de MAKANZA 4	4614
		
19. PROVINCE EDUCATIONNELLE SUD-UBANGI 1 (42)
N°	Nom Antenne	Code Antenne
1	Antenne de GEMENA 1	4201
2	Antenne de GEMENA 2	4202
3	Antenne de GEMENA 3	4203
4	Antenne de BUDJALA 1	4204
5	Antenne de BUDJALA 2	4205
6	Antenne de BUDJALA 3	4206
7	Antenne de BUDJALA 4	4207
8	Antenne de BUDJALA 5	4208
9	Antenne de GEMENA 4	4209
10	Antenne de GEMENA 5	4210
		
20. PROVINCE EDUCATIONNELLE SUD-UBANGI 2 (47)
N°	Nom Antenne	Code Antenne
1	Antenne de KUNGU 1	4701
2	Antenne de KUNGU 2	4702
3	Antenne de KUNGU 3	4703
4	Antenne de KUNGU 4	4704
5	Antenne de KUNGU 5	4705
6	Antenne de LIBENGE 1	4706
7	Antenne de ZONGO	4707
8	Antenne de BOKONZI	4708
9	Antenne de BONYANGA	4709
10	Antenne de GOSUMA	4710
11	Antenne de MOGALO	4711
12	Antenne de LIBENGE 2	4712
13	Antenne de LIBENGE 3	4713
		
21. PROVINCE EDUCATIONNELLE TSHUAPA 1 (43)
N°	Nom Antenne	Code Antenne
1	Antenne de BEFALE 1	4301
2	Antenne de BEFALE 2	4302
3	Antenne de BEFALE 3	4303
4	Antenne de BEFALE 4	4304
5	Antenne de BEFALE 5	4305
6	Antenne de BOENDE 1	4306
7	Antenne de BOENDE 2	4307
8	Antenne de BOENDE 3	4308
9	Antenne de BOENDE 4	4309
10	Antenne de BOENDE 5	4310
11	Antenne de BOENDE 6	4311
12	Antenne de BOENDE 7	4312
13	Antenne de BOENDE 8	4313
14	Antenne de BOENDE 9	4314
15	Antenne de BOENDE 10	4315
16	Antenne de MONKOTO 1	4316
17	Antenne de MONKOTO 2	4317
18	Antenne de MONKOTO 3	4318
19	Antenne de MONKOTO 4	4319
		
22. PROVINCE EDUCATIONNELLE TSHUAPA 2 (43)
N°	Nom Antenne	Code Antenne
1	Antenne de BOKUNGU 1	4301
2	Antenne de BOKUNGU 2	4302
3	Antenne de BOKUNGU 3	4303
4	Antenne de BOKUNGU 4	4304
5	Antenne de BOKUNGU 5	4305
6	Antenne de BOKUNGU 6	4306
7	Antenne de DJOLU 1	4307
8	Antenne de DJOLU 2	4308
9	Antenne de DJOLU 3	4309
10	Antenne de DJOLU 4	4310
11	Antenne de DJOLU 5	4311
12	Antenne de DJOLU 6	4312
13	Antenne de DJOLU 7	4313
14	Antenne d'IKELA1	4314
15	Antenne d'IKELA2	4315
16	Antenne d'IKELA3	4316
17	Antenne d'IKELA4	4317
18	Antenne d'IKELA5	4318
19	Antenne d'IKELA6	4319
20	Antenne de BOKUNGU 7	4320
		
23. PROVINCE EDUCATIONNELLE MONGALA 1 (44)
N°	Nom Antenne	Code Antenne
1	Antenne de LISALA 1	4401
2	Antenne de LISALA 2	4402
3	Antenne de BEDGA 1	4403
4	Antenne de BEDGA 2	4404
5	Antenne de BEDGA 3	4405
6	Antenne de BEDGA 4	4406
7	Antenne de LISALA 3	4409
		
24. PROVINCE EDUCATIONNELLE MONGALA 2 (49)
N°	Nom Antenne	Code Antenne
1	Antenne de BUMBA 1	4901
2	Antenne de BUMBA 2	4902
3	Antenne de BUMBA 3	4903
4	Antenne de BUMBA 4	4904
		
25. PROVINCE EDUCATIONNELLE NORD-UBANGI 1 (45)
N°	Nom Antenne	Code Antenne
1	Antenne de GBADOLITE	4501
2	Antenne de BOSOBOLO 1	4502
3	Antenne de BUSINGA 1	4503
4	Antenne de KARAWA 1	4504
5	Antenne de BODANGABO 1	4505
6	Antenne de BOSOBOLO 2	4506
7	Antenne de BOSOBOLO 3	4507
8	Antenne de BUSINGA 2	4508
9	Antenne de BODANGABO 2	4509
10	Antenne de KARAWA 2	4510
11	Antenne de HOTTO MBANZA	4511
12	Antenne de BOSOBOLO 4	4512
13	Antenne de BOSOBOLO 5	4513
14	Antenne de BOSOBOLO 6	4514
15	Antenne de BONGALA	4515
16	Antenne de MOBAYI 4	4516
		
26. PROVINCE EDUCATIONNELLE NORD-UBANGI 2 (40)
N°	Nom Antenne	Code Antenne
1	Antenne de YAKOMA 1	4001
2	Antenne de YAKOMA 2	4002
3	Antenne de YAKOMA 3	4003
4	Antenne de MOBAYI-MBONGO	4004
5	Antenne de NDAYO	4005
6	Antenne de KANDO	4006
7	Antenne de KOTAKOLI	4007
8	Antenne de WASOLO	4008
9	Antenne de SALONGO	4009
10	Antenne d'UELE	4010
11	Antenne de NZAMBA	4011
12	Antenne de MOVENDA	4012
		
27. PROVINCE EDUCATIONNELLE TSHOPO 1 (51)
N°	Nom Antenne	Code Antenne
1	Antenne de KISANGANI 1	5101
2	Antenne de KISANGANI 2	5102
3	Antenne de BAFWASENDE 1	5103
4	Antenne de BANALIA 1	5104
5	Antenne d'UBUNDU 1	5105
6	Antenne d'UBUNDU 2	5106
7	Antenne de BANALIA 2	5107
8	Antenne d’UBUNDU 3	5108
9	Antenne de BAFWASENDE 2	5109
10	Antenne de KISANGANI 3	5110
		
28. PROVINCE EDUCATIONNELLE TSHOPO 2 (55)
N°	Nom Antenne	Code Antenne
1	Antenne d'ISANGI 1	5501
2	Antenne d'ISANGI 2	5502
3	Antenne de BASOKO 1	5503
4	Antenne d’OPALA 1	5504
5	Antenne d’OPALA 2	5505
6	Antenne de YAHUMA 1	5506
7	Antenne d'ISANGI 3	5507
8	Antenne d'ISANGI 4	5508
9	Antenne d'ISANGI 5	5509
10	Antenne de BASOKO 2	5510
11	Antenne d’OPALA 3	5512
12	Antenne de YAHUMA 2	5513
13	Antenne de BASOKO 3	5514
14	Antenne de YAHUMA 3	5515
		
29. PROVINCE EDUCATIONNELLE ITURI 1 (52)
N°	Nom Antenne	Code Antenne
1	Antenne de BUNIA	5201
2	Antenne de MAMBASA 1	5202
3	Antenne d'IRUMU 1	5203
4	Antenne d'IRUMU 2	5204
5	Antenne de DJUGU 1	5205
6	Antenne de NIZI	5206
7	Antenne d'IRUMU 3	5207
8	Antenne de DJUGU 2	5208
9	Antenne de MAMBASA 2	5209
10	Antenne de MAMBASA 3	5210
		
30. PROVINCE EDUCATIONNELLE ITURI 2 (56)
N°	Nom Antenne	Code Antenne
1	Antenne d'ARU 	5601
2	Antenne d'ARIWARA	5602
3	Antenne d'ADRANGA	5603
4	Antenne d'ATSINIA	5604
5	Antenne d'INGBOKOTO	5605
6	Antenne de LUNDI	5606
7	Antenne de MADO	5607
8	Antenne d’ONDOLEA	5608
9	Antenne de YUKI	5609
		
31. PROVINCE EDUCATIONNELLE ITURI 3 (57)
N°	Nom Antenne	Code Antenne
1	Antenne de MAHAGI 1	5701
2	Antenne de MAHAGI 2/NYALEBE	5702
3	Antenne de MAHAGI 3/NGOTE	5703
4	Antenne de MAHAGI 4/RAMOGI	5704
5	Antenne de MAHAGI 5/NDRELE	5705
6	Antenne de MAHAGI 6/JALASIGA	5706
7	Antenne de MAHAGI 7/DJEGU	5707
8	Antenne de MAHAGI 8/NIOKA	5708
		
32. PROVINCE EDUCATIONNELLE HAUT-UELE 1 (53)
N°	Nom Antenne	Code Antenne
1	Antenne d'ISIRO	5301
2	Antenne de NIANGARA	5302
3	Antenne de RUNGU	5303
4	Antenne de WAMBA 1	5304
5	Antenne de WAMBA 2	5305
		
33. PROVINCE EDUCATIONNELLE HAUT-UELE 2 (53)
N°	Nom Antenne	Code Antenne
1	Antenne de DUNGU	5801
2	Antenne de FARADJE 1	5802
3	Antenne de FARADJE 2	5803
4	Antenne de WATSA 1	5804
5	Antenne de WATSA 2	5805
		
34. PROVINCE EDUCATIONNELLE BAS-UELE (54)
N°	Nom Antenne	Code Antenne
1	Antenne de BUTA	5401
2	Antenne de DINGILA	5402
3	Antenne de BONDO	5403
4	Antenne de POKO	5404
5	Antenne d'AKETI	5405
6	Antenne d'ANGO	5406
		
35. PROVINCE EDUCATIONNELLE NORD-KIVU 1 (61)
N°	Nom Antenne	Code Antenne
1	Antenne de GOMA	6101
2	Antenne de KARISIMBI 1	6102
3	Antenne de NYIRAGONGO	6103
4	Antenne de RUTSHURU 1	6104
5	Antenne de RUTSHURU 2	6105
6	Antenne de RUTSHURU 3	6106
7	Antenne de RUTSHURU 4	6107
8	Antenne de RUTSHURU 5	6108
9	Antenne de KARISIMBI 2	6109
10	Antenne de HIMBI	6110
11	Antenne de KIBUMBA	6111
		
36. PROVINCE EDUCATIONNELLE NORD-KIVU 2 (62)
N°	Nom Antenne	Code Antenne
1	Antenne de BUTEMBO 1	6201
2	Antenne de BENI	6202
3	Antenne de KAMANGO	6203
4	Antenne de LUBERO 1	6204
5	Antenne d'OICHA	6205
6	Antenne de BULONGO	6206
7	Antenne de KYONDO	6207
8	Antenne de KIRUMBA	6208
9	Antenne de NJIAPANDA	6209
10	Antenne de BUTEMBO 2	6211
11	Antenne de KITSUMBIRO	6212
12	Antenne de LUBERO 2	6213
		
37. PROVINCE EDUCATIONNELLE NORD-KIVU 3 (66)
N°	Nom Antenne	Code Antenne
1	Antenne de MASISI 1	6601
2	Antenne de MASISI 2	6602
3	Antenne de MASISI 3	6603
4	Antenne de WALIKALE 1	6604
5	Antenne de WALIKALE 2	6605
6	Antenne de WALIKALE 3	6606
7	Antenne de WALIKALE 4	6607
8	Antenne de MASISI 4	6608
9	Antenne de MASISI 5	6609
10	Antenne de MASISI 6	6610
11	Antenne de MASISI 7	6612
12	Antenne de BWEREMANA	6613
		
38. PROVINCE EDUCATIONNELLE SUD-KIVU 1 (63)
N°	Nom Antenne	Code Antenne
1	Antenne de BUKAVU 1	6301
2	Antenne de BUKAVU 2	6302
3	Antenne de BUKAVU 3	6303
4	Antenne de BUKAVU 4	6316
5	Antenne de KABARE 1	6310
6	Antenne de KABARE 2	6311
7	Antenne de WALUNGU 1	6304
8	Antenne de WALUNGU 2	6305
9	Antenne de WALUNGU 3	6306
10	Antenne de WALUNGU 4	6313
11	Antenne de WALUNGU 5	6314
12	Antenne de KAHELE 1	6307
13	Antenne de KAHELE 2	6308
14	Antenne de KAHELE 3	6309
15	Antenne d'IDJWI 1	6312
16	Antenne d'IDJWI 2	6315
	


	
39. PROVINCE EDUCATIONNELLE SUD-KIVU 2 (65)
N°	Nom Antenne	Code Antenne
1	Antenne de BARAKA	6501
2	Antenne d'UVIRA 1	6502
3	Antenne d'UVIRA 2	6503
4	Antenne d'UVIRA 3	6504
5	Antenne de FIZI 1	6505
6	Antenne de FIZI 3	6506
7	Antenne de FIZI 4	6507
8	Antenne de FIZI 5	6508
		
40. PROVINCE EDUCATIONNELLE SUD-KIVU 3 (67)
N°	Nom Antenne	Code Antenne
1	Antenne de SHABUNDA 1	6701
2	Antenne de SHABUNDA 2	6702
3	Antenne de SHABUNDA 3	6703
4	Antenne de SHABUNDA 4	6704
5	Antenne de MWENGA 1	6705
6	Antenne de MWENGA 2	6706
7	Antenne de MWENGA 3	6707
8	Antenne de MWENGA 4	6708
9	Antenne de MWENGA 5	6709
10	Antenne de SHABUNDA 5	6710
11	Antenne de SHABUNDA 6	6711
12	Antenne de SHABUNDA 7	6712
13	Antenne de SHABUNDA 8	6713
		
41. PROVINCE EDUCATIONNELLE MANIEMA 1 (64)
N°	Nom Antenne	Code Antenne
1	Antenne de KASUKU	6401
2	Antenne de KAILO 1	6402
3	Antenne de KALIMA	6403
4	Antenne de PANGI	6409
5	Antenne de LUBUTU	6412
6	Antenne de PUNIA	6413
7	Antenne de MIKELENGE	6416
8	Antenne d’ALUNGULI	6417
9	Antenne de KAILO 2	6418
		
42. PROVINCE EDUCATIONNELLE MANIEMA 2 (68)
N°	Nom Antenne	Code Antenne
1	Antenne de KABAMBARE	6801
2	Antenne de KASONGO 1	6802
3	Antenne de KASONGO 2	6803
4	Antenne de KIBOMBO 1	6804
5	Antenne de KUNDA 1	6805
6	Antenne de LWAMA	6806
7	Antenne de WAMAZA	6807
8	Antenne de KUNDA 2	6808
9	Antenne de KASONGO 3	6809
10	Antenne de KIBOMBO 2	6810
		
43. PROVINCE EDUCATIONNELLE HAUT-KATANGA 1 (71)
N°	Nom Antenne	Code Antenne
1	Antenne de LUBUMBASHI 1	7101
2	Antenne de LUBUMBASHI 2	7102
3	Antenne de LUBUMBASHI 3	7103
4	Antenne de LUBUMBASHI 4	7104
5	Antenne de KIPUSHI	7106
6	Antenne de LIKASI 1	7107
7	Antenne de KAMBOVE	7108
8	Antenne de SAKANIA	7111
9	Antenne de LIKASI 2	7112
10	Antenne de LUBUMBASHI 5	7113
		
44. PROVINCE EDUCATIONNELLE HAUT-KATANGA 2 (76)
N°	Nom Antenne	Code Antenne
1	Antenne de KASENGA	7601
2	Antenne de KILWA	7602
3	Antenne de MITWABA	7603
4	Antenne de PUETO	7604
		
45. PROVINCE EDUCATIONNELLE TANGANYIKA 1 (73)
N°	Nom Antenne	Code Antenne
1	Antenne de KALEMI 1	7301
2	Antenne de KALEMI 2	7302
3	Antenne de MOBA 1	7304
4	Antenne de MOBA 2	7305
5	Antenne de KALEMIE 3	7903
6	Antenne de NYUNZU 1	7306
7	Antenne de NYUNZU 2	7307
		
46. PROVINCE EDUCATIONNELLE TANGANYIKA 2 (77)
N°	Nom Antenne	Code Antenne
1	Antenne d'ANKORO 1	7701
2	Antenne de KABALO 1/CENTRE	7702
3	Antenne de KONGOLO 1	7703
4	Antenne de KONGOLO 2	7704
5	Antenne de KONGOLO 3	7705
6	Antenne de KONGOLO 4	7706
7	Antenne de MANONO 1	7707
8	Antenne de KABALO 2	7708
9	Antenne de MANONO 2	7709
10	Antenne d'ANKORO 2	7710
11	Antenne de KABALO 3	7711
		
47. PROVINCE EDUCATIONNELLE LUALABA 1 (74)
N°	Nom Antenne	Code Antenne
1	Antenne de KOLWEZI 1	7401
2	Antenne de KOLWEZI 2	7402
3	Antenne de MUTSHATSHA 	7403
4	Antenne de LUBUDI 1	7404
5	Antenne de LUBUDI 2	7405
		
48. PROVINCE EDUCATIONNELLE LUALABA 2 (78)
N°	Nom Antenne	Code Antenne
1	Antenne de DILOLO 1	7801
2	Antenne de DILOLO 2	7802
3	Antenne de KAPANGA 1	7803
4	Antenne de KAPANGA 2	7804
5	Antenne de KAPANGA 3	7805
6	Antenne de SANDOA 1	7806
7	Antenne de SANDOA 2	7807
		
49. PROVINCE EDUCATIONNELLE HAUT-LOMAMI 1 (72)
N°	Nom Antenne	Code Antenne
1	Antenne de KAMINA 1	7201
2	Antenne de KAMINA 2	7202
3	Antenne de KABONGO 1	7203
4	Antenne de KABONGO 2	7204
5	Antenne de KYONDO KYA MBIDI	7205
6	Antenne de KANIAMA 1	7206
7	Antenne de KABONGO 3	7208
8	Antenne de KABONGO 4	7209
9	Antenne de KANIAMA 2	7210
10	Antenne de KAYAMBA 1	7211
11	Antenne de KAMINA 3	7212
12	Antenne de KAYAMBA 2	7213
		
50. PROVINCE EDUCATIONNELLE HAUT-LOMAMI 2 (75)
N°	Nom Antenne	Code Antenne
1	Antenne de BUKAMA 1	7501
2	Antenne de BUKAMA 2	7502
3	Antenne de MALEMBA-NKULU 1	7503
4	Antenne de MALEMBA-NKULU 2	7504
5	Antenne de BUKAMA 3	7505
6	Antenne de BUKAMA 4	7506
7	Antenne de MALEMBA-NKULU 3	7507
8	Antenne de MALEMBA-NKULU 4	7508
9	Antenne de MALEMBA-NKULU 5	7509
		
51. PROVINCE EDUCATIONNELLE KASAI-CENTRAL 1 (81)
N°	Nom Antenne	Code Antenne
1	Antenne de KANANGA 1	8101
2	Antenne de KANANGA 2	8102
3	Antenne de DIBAYA 1	8103
4	Antenne de DEMBA 1	8104
5	Antenne de DEMBA 2	8105
6	Antenne de DIMBELENGE 1	8106
7	Antenne de DIBAYA 2	8107
8	Antenne de DIMBELENGE 2	8108
9	Antenne de DIBAYA 3	8109
10	Antenne de DIMBELENGE 3	8110
11	Antenne de MUNKAMBA	8111
12	Antenne de LUBUNGA	8112
		
52. PROVINCE EDUCATIONNELLE KASAI-CENTRAL 2  (83)
N°	Nom Antenne	Code Antenne
1	Antenne de LUIZA 1	8301
2	Antenne de LUIZA 2	8302
3	Antenne de KAZUMBA CENTRE	8303
4	Antenne de KAZUMBA SUD 1	8304
5	Antenne de KAZUMBA SUD 2	8305
6	Antenne de LUIZA 3	8306
7	Antenne de LUIZA 4	8307
8	Antenne de KAZUMBA NORD 1	8308
9	Antenne de KAZUMBA NORD 2	8309
10	Antenne de LUIZA 5	8310
11	Antenne de LUIZA 6	8311
12	Antenne de BAMBAIE	8312
		
53. PROVINCE EDUCATIONNELLE KASAI 1  (82)
N°	Nom Antenne	Code Antenne
1	Antenne de TSHIKAPA 1	8201
2	Antenne de TSHIKAPA 2	8202
3	Antenne de NYANGA	8203
4	Antenne de KAMUESHA	8204
5	Antenne de SHABUANDA	8205
6	Antenne de KITANGUA	8206
7	Antenne de LUEBO 3	8207
8	Antenne de KAMONIA	8208
9	Antenne de KADANGA	8209
10	Antenne de LUEBO 3	8210
11	Antenne de LUNYEKA	8211
12	Antenne de KABAMBAYI	8212
13	Antenne de KASADISADI	8213
14	Antenne de KANZALA	8214
15	Antenne de DIBUMBA 2	8215
16	Antenne de BIAKABOMBA	8216
17	Antenne de MUTENA	8217
		
54. PROVINCE EDUCATIONNELLE KASAI 2  (84)
N°	Nom Antenne	Code Antenne
1	Antenne d'ILEBO 1/CITE	8401
2	Antenne de MAPANGU	8402
3	Antenne de MIBALAYI	8403
4	Antenne de SUD-BANGA	8404
5	Antenne de MWEKA	8405
6	Antenne de KAKENGE	8406
7	Antenne de BAKATOMBI	8407
8	Antenne de DEKESE 1	8408
9	Antenne de DEKESE 2	8409
10	Antenne de LUEBO	8410
11	Antenne de DEKESE 3	8411
12	Antenne de MISUMBA	8412
13	Antenne de DOMIONGO	8413
		
55. PROVINCE EDUCATIONNELLE KASAI ORIENTAL 1 (91)
N°	Nom Antenne	Code Antenne
1	Antenne de MBUJI-MAYI 1	9101
2	Antenne de MBUJI-MAYI 2	9102
3	Antenne de MBUJI-MAYI 3	9103
4	Antenne de TSHILENGE 1	9104
5	Antenne de TSHILENGE 2	9105
6	Antenne de KATANDA 1	9106
7	Antenne de KATANDA 2	9107
8	Antenne de LUPATAPATA	9108
		
56. PROVINCE EDUCATIONNELLE KASAI ORIENTAL 2 (94)
N°	Nom Antenne	Code Antenne
1	Antenne de KABEYA KAMUANGA 1	9401
2	Antenne de KABEYA KAMUANGA 2	9402
3	Antenne de MIABI 1	9403
4	Antenne de MIABI 2	9404
		
57. PROVINCE EDUCATIONNELLE SANKURU 1 (92)
N°	Nom Antenne	Code Antenne
1	Antenne de LODJA 1	9203
2	Antenne de LODJA 2	9204
3	Antenne de LODJA 3	9205
4	Antenne de KOLE 1	9208
5	Antenne de KOLE 2	9209
6	Antenne de KOLE 3	9210
7	Antenne de LOMELA 1	9211
8	Antenne de LOMELA 2	9212
9	Antenne de LOMELA 3	9213
10	Antenne de LODJA 4	9217
11	Antenne de LODJA 5	9218
12	Antenne de KOLE 4	9222
		
58. PROVINCE EDUCATIONNELLE SANKURU 2 (95)
N°	Nom Antenne	Code Antenne
1	Antenne de LUSAMBO 1	9501
2	Antenne de LUSAMBO 2	9502
3	Antenne de LUSAMBO 3	9503
4	Antenne de LUSAMBO 4	9504
5	Antenne de LUSAMBO 5	9505
6	Antenne de LUBEFU 1	9506
7	Antenne de LUBEFU 2	9507
8	Antenne de LUBEFU 3	9508
9	Antenne de LUBEFU 4	9509
10	Antenne de LUBEFU 5	9510
11	Antenne de KATAKO 1	9511
12	Antenne de KATAKO 2	9512
13	Antenne de KATAKO 3	9513
14	Antenne de KATAKO 4	9514
15	Antenne de KATAKO 5	9515
16	Antenne de KATAKO 6	9516
		
59. PROVINCE EDUCATIONNELLE LOMAMI 1 (95)
N°	Nom Antenne	Code Antenne
1	Antenne de KABINDA 1	9301
2	Antenne de KABINDA 2	9302
3	Antenne de KABINDA 3	9303
4	Antenne de LUBAO 1	9304
5	Antenne de LUBAO 2	9305
6	Antenne de LUBAO 3	9306
7	Antenne de LUKASHI BADIMBI	9307
8	Antenne de BASANGA	9308
9	Antenne de NGANDAJIKA 3	9309
10	Antenne de KISENGWA	9310
11	Antenne de LUMBILUKULA 1	9311
12	Antenne de NVUNAYI	9312
13	Antenne de SENTERY	9313
14	Antenne de BALUBALU-BANGULA	9314
15	Antenne de LUDIMBILUKULA 2	9315
		
60. PROVINCE EDUCATIONNELLE LOMAMI 2 (96)
N°	Nom Antenne	Code Antenne
1	Antenne de MWENE-DITU	9601
2	Antenne de LUILU 1	9602
3	Antenne de NGANDAJIKA 1	9603
4	Antenne de NGANDAJIKA 2	9604
5	Antenne de KAMIJI	9605
6	Antenne de KANYITSHIN	9606
7	Antenne de LUILU 2	9607
8	Antenne de LUILU 3	9608
9	Antenne de KALAMBAYI	9609
10	Antenne de KATSHISUNGU	9610
		
Total	638 Antennes
*/