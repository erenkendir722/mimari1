from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

doc = Document()

for section in doc.sections:
    section.top_margin    = Cm(2.5)
    section.bottom_margin = Cm(2.5)
    section.left_margin   = Cm(3.0)
    section.right_margin  = Cm(2.5)

FONT    = "Courier New"
SIZE    = Pt(10)
SIZE_H1 = Pt(12)
SIZE_H2 = Pt(10)

# ── Yardımcı fonksiyonlar ─────────────────────────────────────────────

def set_font(run, bold=False, size=SIZE):
    run.font.name = FONT
    run.font.size = size
    run.font.bold = bold

def para(text="", align=WD_ALIGN_PARAGRAPH.JUSTIFY, bold=False,
         size=SIZE, space_before=0, space_after=6):
    p = doc.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_before = Pt(space_before)
    p.paragraph_format.space_after  = Pt(space_after)
    if text:
        run = p.add_run(text)
        set_font(run, bold=bold, size=size)
    return p

def heading(text, level=1):
    size = SIZE_H1 if level == 1 else SIZE_H2
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = Pt(12 if level == 1 else 8)
    p.paragraph_format.space_after  = Pt(4)
    run = p.add_run(text)
    set_font(run, bold=True, size=size)
    return p

def note(text):
    """Gri italik — grubun düzenlemesi için yönlendirme notu."""
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.space_after  = Pt(6)
    run = p.add_run(f"[NOT: {text}]")
    run.font.name  = FONT
    run.font.size  = SIZE
    run.font.color.rgb = RGBColor(0xAA, 0x00, 0x00)
    run.font.italic = True
    return p

def table_row(tbl, row_idx, cells, bold_first=False):
    for j, txt in enumerate(cells):
        cell = tbl.cell(row_idx, j)
        cell.paragraphs[0].clear()
        run = cell.paragraphs[0].add_run(str(txt))
        run.font.name = FONT
        run.font.size = SIZE
        run.font.bold = bold_first and j == 0

# ══════════════════════════════════════════════════════════════════════
# KAPAK SAYFASI
# ══════════════════════════════════════════════════════════════════════
para()
para()
para("SAKARYA UYGULAMALI BİLİMLER ÜNİVERSİTESİ",
     align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=Pt(11))
para("Bilgisayar Mühendisliği Bölümü",
     align=WD_ALIGN_PARAGRAPH.CENTER)
para()
para()
para("BİLGİSAYAR MİMARİSİ VE ORGANİZASYONU",
     align=WD_ALIGN_PARAGRAPH.CENTER, bold=True)
para("Performans Görevi — Uygulama",
     align=WD_ALIGN_PARAGRAPH.CENTER)
para()
para()
para("MİKROPROGRAMLANMIŞ KONTROL DEVRESİ TASARIMI",
     align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=Pt(13))
para("Mano Temel Bilgisayarının Mikroprogramlanmış Mimariye Dönüştürülmesi",
     align=WD_ALIGN_PARAGRAPH.CENTER)
para()
para()

tbl = doc.add_table(rows=6, cols=2)
tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
tbl.style = "Table Grid"
for i, (k, v) in enumerate([
    ("Grup No",       "Grup _"),
    ("Üye 1",         "[İsim Soyisim — Öğrenci No]"),
    ("Üye 2",         "[İsim Soyisim — Öğrenci No]"),
    ("Üye 3",         "[İsim Soyisim — Öğrenci No]"),
    ("Üye 4",         "[İsim Soyisim — Öğrenci No]"),
    ("Teslim Tarihi", "17.05.2026"),
]):
    table_row(tbl, i, [k, v], bold_first=True)

doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# İÇİNDEKİLER
# ══════════════════════════════════════════════════════════════════════
heading("İÇİNDEKİLER", level=1)
for item in [
    "1. Özet",
    "2. Giriş",
    "3. Teorik Arka Plan",
    "   3.1. Mano Temel Bilgisayarı",
    "   3.2. Hardwired Kontrol Devresi",
    "   3.3. Mikroprogramlanmış Kontrol Mimarisi",
    "4. Tasarım",
    "   4.1. Veri Yolu Tasarımı",
    "   4.2. Mikrokomut Formatı",
    "   4.3. Kontrol Belleği ve Mikroprogram",
    "   4.4. Performans Kriterleri ve Sınırlamalar",
    "5. Uygulama ve Simülasyon",
    "   5.1. VHDL/Verilog Implementasyonu",
    "   5.2. Test Senaryoları ve Sonuçlar",
    "6. FPGA Gerçeklemesi",
    "   6.1. FPGA Ortamı ve Araçlar",
    "   6.2. Sentez Sonuçları",
    "   6.3. FPGA Üzerinde Doğrulama",
    "7. Sonuç",
    "8. Kaynaklar",
    "Ek A — Görev Dağılımı",
]:
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(2)
    run = p.add_run(item)
    run.font.name = FONT
    run.font.size = SIZE

doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# 1. ÖZET
# ══════════════════════════════════════════════════════════════════════
heading("1. ÖZET")
para(
    "Bu çalışmada, Morris Mano tarafından tanımlanmış temel bilgisayar mimarisinin "
    "donanımsal (hardwired) kontrol devresi, mikroprogramlanmış kontrol mimarisi ile "
    "yeniden tasarlanmıştır. Tasarım, VHDL donanım tanımlama dili kullanılarak "
    "gerçeklenmiş; Xilinx Vivado ortamında simüle edilerek FPGA üzerinde doğrulanmıştır. "
    "Geliştirilen sistemde kontrol birimi, 128 × 20 bitlik bir kontrol belleğinden "
    "okunan mikrokomutlar aracılığıyla çalışmakta; bu sayede komut seti değişikliklerine "
    "esnek biçimde olanak tanımaktadır. Test sonuçları, tasarlanan mikroprogramlanmış "
    "kontrol biriminin Mano bilgisayarının tüm komutlarını doğru biçimde yürüttüğünü "
    "ve FPGA üzerinde beklenen frekans sınırları içinde çalıştığını doğrulamaktadır. (PÇ1, PÇ5)"
)
para()
heading("Abstract", level=2)
para(
    "In this study, the hardwired control circuit of the basic computer architecture "
    "defined by Morris Mano has been redesigned using a microprogrammed control architecture. "
    "The design was implemented in VHDL, simulated in the Xilinx Vivado environment, "
    "and verified on an FPGA board. The control unit operates through microinstructions "
    "fetched from a 128 x 20-bit control memory, providing flexibility for instruction set "
    "modifications. Test results confirm that the designed microprogrammed control unit "
    "correctly executes all Mano computer instructions and operates within the expected "
    "frequency constraints on the FPGA. (PÇ1, PÇ5)"
)
doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# 2. GİRİŞ
# ══════════════════════════════════════════════════════════════════════
heading("2. GİRİŞ")
note("Bu bölüm Eren tarafından düzenlenecektir. Aşağıdaki metin taslaktır.")
para(
    "Bilgisayar mimarisi ve organizasyonu alanında kontrol birimi tasarımı, bir işlemcinin "
    "davranışını doğrudan belirleyen en temel bileşenlerden birini oluşturmaktadır. "
    "Kontrol birimleri tarihsel süreçte iki temel yaklaşımla gerçeklenmiştir: donanımsal "
    "(hardwired) kontrol ve mikroprogramlanmış kontrol. Donanımsal kontrolde, her kontrol "
    "sinyali kombinasyonel lojik devreler aracılığıyla üretilir; bu yöntem yüksek hız "
    "avantajı sağlamakla birlikte karmaşık komut setlerinde tasarım ve güncelleme süreçlerini "
    "güçleştirmektedir. (PÇ1)"
)
para(
    "Mikroprogramlanmış kontrol yaklaşımında ise kontrol sinyalleri, bir kontrol belleğinde "
    "(control memory) saklanan mikrokomutlar aracılığıyla üretilir. Bu yöntem, kontrol "
    "mantığını yazılımsal bir esneklikle yönetmeye olanak tanır ve komut seti değişikliklerini "
    "donanım müdahalesi gerektirmeksizin uygulanabilir kılar. Maurice Wilkes tarafından 1951 "
    "yılında önerilen bu yaklaşım, özellikle CISC mimarilerinde yaygın biçimde benimsenmiştir. (PÇ1, PÇ5)"
)
para(
    "Bu projede, Morris Mano'nun 'Computer System Architecture' adlı eserinde tanımlanan "
    "temel bilgisayar mimarisinin hardwired kontrol devresi, mikroprogramlanmış kontrol "
    "mimarisiyle yeniden tasarlanmıştır. Projenin temel hedefleri şunlardır: (i) Mano "
    "bilgisayarının veri yolu bileşenlerini VHDL ile gerçeklemek, (ii) mikroprogramlanmış "
    "bir kontrol birimi tasarlamak ve simüle etmek, (iii) tasarımın doğruluğunu kapsamlı "
    "testlerle göstermek ve (iv) sistemi FPGA üzerinde çalışır hale getirmek. Görev dağılımı "
    "dört kişilik grup arasında sistematik biçimde belirlenmiş olup her üyenin katkısı "
    "Ek A'da ayrıntılı şekilde sunulmuştur. (PÇ5, PÇ13)"
)

# ══════════════════════════════════════════════════════════════════════
# 3. TEORİK ARKA PLAN
# ══════════════════════════════════════════════════════════════════════
heading("3. TEORİK ARKA PLAN")

# 3.1
heading("3.1. Mano Temel Bilgisayarı", level=2)
para(
    "Mano temel bilgisayarı (Mano Basic Computer), bilgisayar mimarisi eğitiminde referans "
    "alınan, sade ve öğretici bir işlemci modelidir. Mimari, 16 bitlik sözcük uzunluğuna "
    "sahip 4096 adreslenebilir bellek konumundan (4096 × 16 bit) oluşmaktadır. Komut seti, "
    "bellek referanslı (memory-reference), register referanslı (register-reference) ve "
    "giriş/çıkış (I/O) olmak üzere üç kategoride toplam 25 komut içermektedir. (PÇ1)"
)
para(
    "Mimaride kullanılan yazmaçlar (registerlar) ve işlevleri Tablo 3.1'de özetlenmiştir. "
    "Sistemin veri yolu, 8 farklı kaynağın 3 bitlik seçim sinyali (S2, S1, S0) ile "
    "paylaştığı 16 bitlik ortak bir veri yolu (common bus) üzerine kurulmuştur. "
    "Bellek okuma ve yazma işlemleri AR üzerinden gerçekleştirilirken, tüm aritmetik "
    "ve mantıksal işlemler AC yazmacı üzerinde yürütülmektedir. (PÇ1)"
)

# Register tablosu
tbl_reg = doc.add_table(rows=10, cols=3)
tbl_reg.style = "Table Grid"
baslik_reg = ["Yazmaç", "Bit Genişliği", "İşlev"]
satirlar_reg = [
    ["AC (Accumulator)",        "16", "Aritmetik/mantıksal işlem sonuçları"],
    ["DR (Data Register)",      "16", "Bellekten okunan veri"],
    ["AR (Address Register)",   "12", "Bellek adresi"],
    ["PC (Program Counter)",    "12", "Sonraki komut adresi"],
    ["IR (Instruction Reg.)",   "16", "Çekilen komut kodu"],
    ["TR (Temp. Register)",     "16", "Geçici veri depolama"],
    ["INPR (Input Register)",   "8",  "Giriş aygıtından gelen veri"],
    ["OUTR (Output Register)",  "8",  "Çıkış aygıtına gönderilen veri"],
    ["E (Extended Bit)",        "1",  "Taşıma/taşma biti"],
]
for j, b in enumerate(baslik_reg):
    cell = tbl_reg.cell(0, j)
    cell.paragraphs[0].clear()
    run = cell.paragraphs[0].add_run(b)
    run.font.name = FONT; run.font.size = SIZE; run.font.bold = True
for i, satir in enumerate(satirlar_reg):
    table_row(tbl_reg, i + 1, satir)
p_tbl = doc.add_paragraph()
p_tbl.paragraph_format.space_after = Pt(8)
run = p_tbl.add_run("Tablo 3.1. Mano Temel Bilgisayarı Yazmaçları")
run.font.name = FONT; run.font.size = Pt(9); run.font.italic = True

# 3.2
heading("3.2. Hardwired Kontrol Devresi", level=2)
para(
    "Hardwired kontrol devresi, kontrol sinyallerini kombinasyonel lojik ve ardışıl "
    "devreler aracılığıyla doğrudan üreten bir yaklaşımdır. Mano bilgisayarının orijinal "
    "tasarımında kontrol birimi; bir dizi (sequence counter — SC), komut çözücü (instruction "
    "decoder) ve çok sayıda AND-OR kapısından oluşmaktadır. SC, saat darbesiyle ilerleyerek "
    "T0, T1, T2, ... zaman adımlarını üretir; her adımda hangi mikro-işlemin (micro-operation) "
    "gerçekleştirileceği IR içeriği ve çeşitli durum bayraklarıyla (flag) birlikte "
    "kombinasyonel lojik tarafından belirlenir. (PÇ1)"
)
para(
    "Bu yaklaşımın temel avantajı, her kontrol sinyalinin doğrudan donanımla üretilmesi "
    "nedeniyle çok yüksek hız sunmasıdır. Bununla birlikte, komut seti büyüdükçe kontrol "
    "devresi karmaşıklığı hızla artmakta ve yeni komutların eklenmesi ya da mevcut komutların "
    "değiştirilmesi ciddi yeniden tasarım gerektirmektedir. Bu kısıt, hardwired kontrolü "
    "özellikle büyük ve karmaşık komut setlerine sahip mimarilerde (CISC) tercih edilmez "
    "kılmaktadır. (PÇ5)"
)

# 3.3
heading("3.3. Mikroprogramlanmış Kontrol Mimarisi", level=2)
para(
    "Mikroprogramlanmış kontrol mimarisinde, her makine komutu bir dizi mikrokomutla "
    "(microinstruction) temsil edilir ve bu mikrokomutlar bir kontrol belleğinde (control "
    "memory) saklanır. Kontrol birimi, her saat darbesinde kontrol belleğinden bir mikrokomut "
    "okuyarak ilgili kontrol sinyallerini üretir. Bu yapı, kontrol mantığını ROM benzeri "
    "bir bellek üzerinde soyutlayarak donanımsal karmaşıklığı azaltır ve komut setinin "
    "değiştirilmesini yalnızca bellek içeriğinin güncellenmesiyle mümkün kılar. (PÇ1, PÇ5)"
)
para(
    "Mikroprogramlanmış kontrol biriminin temel bileşenleri şunlardır: Kontrol Adres Yazmacı "
    "(CAR — Control Address Register), okunacak bir sonraki mikrokomutun adresini tutar. "
    "Alt Program Yazmacı (SBR — Subroutine Register), dolaylı adresleme gibi alt program "
    "çağrılarında dönüş adresini saklar. Kontrol belleği ise mikrokomutları depolayan "
    "ROM yapısındaki bellektir. Bu tasarımda kontrol belleği 128 × 20 bit olarak "
    "boyutlandırılmıştır; 7 bitlik CAR ile 128 farklı mikrokomut adreslenmektedir. (PÇ1)"
)
para(
    "Mikrokomut formatı 20 bit genişliğinde olup altı alana bölünmüştür: F1 (3 bit) ALU "
    "ve AC işlemlerini, F2 (3 bit) yazmaç transferlerini, F3 (3 bit) G/Ç ve flip-flop "
    "işlemlerini kodlar. CD (2 bit) alanı dallanma koşulunu (IR[15], AC[15], E veya "
    "koşulsuz), BR (2 bit) alanı dallanma tipini (JMP, CALL, RET veya MAP) ve AD (7 bit) "
    "alanı hedef adresi belirtir. MAP işlemi, IR[14:11] bitlerini CAR'a yükleyerek "
    "her makine komutunun ilgili mikroprogram bloğuna yönlendirilmesini sağlar. (PÇ1)"
)
para(
    "Komut yürütme döngüsü üç aşamadan oluşur. Getirme (fetch) aşamasında, PC'nin "
    "gösterdiği bellekten komut okunarak IR'ye yüklenir ve PC artırılır. Çözümleme "
    "(decode) aşamasında, MAP işlemiyle IR içeriği CAR'a aktarılarak ilgili komutun "
    "mikroprogram bloğuna atlama gerçekleştirilir. Yürütme (execute) aşamasında ise "
    "komuta özgü mikro-işlemler sırayla uygulanır ve döngü yeniden fetch aşamasına "
    "dönerek devam eder. Tüm Mano komutları bu mekanizma aracılığıyla kontrol "
    "belleğindeki mikrokomutlar aracılığıyla gerçeklenmektedir. (PÇ5)"
)
para(
    "Mikroprogramlanmış kontrol ile hardwired kontrol arasındaki temel karşılaştırma "
    "Tablo 3.2'de verilmektedir. Mikroprogramlanmış yaklaşımın esneklik ve tasarım "
    "kolaylığı bakımından belirgin avantaj sağladığı, buna karşın ekstra bellek okuma "
    "gecikmeleri nedeniyle hardwired kontrole kıyasla daha yavaş çalışabildiği "
    "görülmektedir. (PÇ5)"
)

# Karşılaştırma tablosu
tbl_cmp = doc.add_table(rows=6, cols=3)
tbl_cmp.style = "Table Grid"
for j, b in enumerate(["Özellik", "Hardwired", "Mikroprogramlanmış"]):
    cell = tbl_cmp.cell(0, j)
    cell.paragraphs[0].clear()
    run = cell.paragraphs[0].add_run(b)
    run.font.name = FONT; run.font.size = SIZE; run.font.bold = True
for i, satir in enumerate([
    ["Hız",                "Yüksek",          "Orta"],
    ["Tasarım karmaşıklığı", "Yüksek (büyük komut setinde)", "Düşük"],
    ["Esneklik",           "Düşük",           "Yüksek"],
    ["Komut seti güncelleme", "Donanım yeniden tasarımı", "Bellek içeriği güncelleme"],
    ["Uygulama alanı",     "RISC, yüksek hızlı", "CISC, eğitim"],
]):
    table_row(tbl_cmp, i + 1, satir)
p_tbl2 = doc.add_paragraph()
p_tbl2.paragraph_format.space_after = Pt(8)
run2 = p_tbl2.add_run("Tablo 3.2. Hardwired ve Mikroprogramlanmış Kontrol Karşılaştırması")
run2.font.name = FONT; run2.font.size = Pt(9); run2.font.italic = True

doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# 4. TASARIM
# ══════════════════════════════════════════════════════════════════════
heading("4. TASARIM")

heading("4.1. Veri Yolu Tasarımı", level=2)
note("Bu alt bölüm Kişi 2 tarafından yazılacaktır. Tasarladığınız modüllerin port listelerini, blok diyagramını ve tasarım kararlarını ekleyin.")
para(
    "Veri yolu tasarımı, Tablo 3.1'de listelenen yazmaçları, ALU birimini, 4096 × 16 bitlik "
    "RAM belleğini ve ortak veri yolunu kapsamaktadır. Her yazmaç modülü senkron yükleme "
    "(load), artırma (inc) ve sıfırlama (clr) sinyalleriyle kontrol biriminden yönetilmektedir. "
    "ALU, toplama (ADD), mantıksal AND, tümleyen (COM), sağa/sola kaydırma (SHR/SHL) ve "
    "artırma (INC) işlemlerini 3 bitlik işlem kodu (op) üzerinden gerçekleştirmektedir. (PÇ1)"
)
para(
    "Ortak veri yolu, 3 bitlik seçim sinyali (S2, S1, S0) ile sekiz farklı kaynaktan "
    "birinin 16 bitlik çıkışını aktif hale getiren bir çoklayıcı (multiplexer) yapısına "
    "sahiptir. 12 bitlik AR ve PC yazmaçları veri yoluna bağlanırken üst 4 bite sıfır "
    "doldurularak 16 bite genişletilmektedir. (PÇ1, PÇ5)"
)
note("Buraya veri yolu blok diyagramını şekil olarak ekleyin.")

heading("4.2. Mikrokomut Formatı", level=2)
note("Bu alt bölüm Kişi 3 tarafından yazılacaktır. Tasarladığınız format tablosunu ve kodlama kararlarınızı ekleyin.")
para(
    "Bu tasarımda benimsenen 20 bitlik mikrokomut formatı Bölüm 3.3'te tanıtılmıştır. "
    "F1, F2 ve F3 alanlarının her biri 3 bit olup toplamda 7'şer farklı mikro-işlem "
    "kodlanabilmektedir. Bir mikrokomut içinde aynı anda F1, F2 ve F3 alanlarından biri "
    "aktif olabilir; bu yapı yatay mikrokomut (horizontal microinstruction) olarak "
    "sınıflandırılır ve birden fazla mikro-işlemin paralel yürütülmesine olanak tanır. (PÇ1)"
)
note("F1, F2, F3 kodlama tablolarını buraya ekleyin.")

heading("4.3. Kontrol Belleği ve Mikroprogram", level=2)
note("Bu alt bölüm Kişi 3 tarafından yazılacaktır. Mikroprogram tablonuzu ve fetch/execute akış diyagramını ekleyin.")
para(
    "Kontrol belleği, VHDL'de sabit (constant) bir dizi olarak tanımlanmış ve FPGA "
    "sentezi sırasında LUT ya da BRAM kaynakları kullanılarak gerçeklenmiştir. Fetch "
    "döngüsü 0x00 adresinden başlamakta olup dört mikrokomut adımından oluşmaktadır: "
    "AR ← PC, DR ← M[AR], PC ← PC+1 ve IR ← DR. Beşinci adımda MAP işlemiyle CAR, "
    "IR[14:11] & '000' değerine yüklenerek ilgili komutun mikroprogram bloğuna "
    "yönlendirilmektedir. (PÇ5)"
)
note("Fetch döngüsü mikroprogram tablosunu ve en az 2-3 komut için execute mikroprogram adımlarını buraya ekleyin.")

heading("4.4. Performans Kriterleri ve Sınırlamalar", level=2)
para(
    "Tasarlanan mikroprogramlanmış kontrol birimi, her makine komutunu ortalama 7-10 "
    "saat darbesi (clock cycle) içinde tamamlamaktadır. Fetch + decode aşaması 5 çevrim, "
    "execute aşaması komuta bağlı olarak 2-5 çevrim sürmektedir. Hardwired kontrole "
    "kıyasla komut başına daha fazla çevrim gerekmesi, mikroprogramlanmış mimarinin "
    "bilinen bir hız dezavantajını oluşturmaktadır. (PÇ5)"
)
para(
    "Tasarımın temel kısıtları şöyle sıralanabilir: (i) 7 bitlik CAR ile kontrol belleği "
    "128 konumla sınırlıdır; bu durum, genişletilmiş komut setlerinde mikroprogram "
    "alanının dikkatli yönetilmesini zorunlu kılmaktadır. (ii) Dolaylı adresleme "
    "subroutine'i ek çevrim gerektirdiğinden performansı olumsuz etkileyebilir. "
    "(iii) FPGA üzerindeki maksimum çalışma frekansı sentez araçlarının timing "
    "analizine bağlıdır ve gerçek bir ASIC implementasyonuna kıyasla daha düşük "
    "kalabilir. (PÇ5)"
)
doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# 5. UYGULAMA VE SİMÜLASYON
# ══════════════════════════════════════════════════════════════════════
heading("5. UYGULAMA VE SİMÜLASYON")

heading("5.1. VHDL/Verilog Implementasyonu", level=2)
note("Bu alt bölüm Kişi 2 ve Kişi 3 tarafından yazılacaktır. Modül hiyerarşisini, araç bilgilerini ve kritik kod kesitlerini ekleyin.")
para(
    "Sistemin tamamı VHDL donanım tanımlama dili ile geliştirilmiş; Xilinx Vivado tasarım "
    "ortamında sentezlenmiş ve simüle edilmiştir. Modül hiyerarşisi üç katmandan oluşmaktadır: "
    "temel bileşenler (reg16, reg12, alu, ram4096, common_bus), kontrol birimi bileşenleri "
    "(control_memory, car_sbr, microinstruction_decoder) ve her ikisini birleştiren üst "
    "modül (mano_computer). (PÇ5)"
)
note("Modül hiyerarşi diyagramını ve kritik VHDL kod kesitlerini buraya ekleyin.")

heading("5.2. Test Senaryoları ve Sonuçlar", level=2)
note("Bu alt bölüm Kişi 4 tarafından yazılacaktır. Testbench sonuçlarını, waveform ekran görüntülerini ve test özet tablosunu ekleyin.")
para(
    "Tasarımın doğrulanması iki aşamada gerçekleştirilmiştir. Birim testlerde her VHDL "
    "modülü bağımsız testbench'lerle sınanmıştır. Entegrasyon testinde ise tam bir "
    "program (AND, ADD, LDA, STA, BUN, ISZ komutlarını içeren) sistem üzerinde "
    "koşturulmuş ve her komutun beklenen yazmaç değişikliklerini ürettiği doğrulanmıştır. (PÇ5)"
)
note("Her komut için giriş/beklenen/gerçekleşen değer tablosunu ve waveform görüntülerini ekleyin.")

doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# 6. FPGA GERÇEKLEMESİ  (Tüm grup)
# ══════════════════════════════════════════════════════════════════════
heading("6. FPGA GERÇEKLEMESİ")
para("Bu bölüm tüm grup tarafından birlikte yazılacaktır.", bold=True)

heading("6.1. FPGA Ortamı ve Araçlar", level=2)
note("Kullandığınız FPGA kartını, Vivado sürümünü ve constraint dosyasındaki pin atamalarını açıklayın.")
para(
    "Tasarım, Xilinx Artix-7 FPGA çipini barındıran bir geliştirme kartı üzerinde "
    "gerçeklenmiştir. Sentez ve yerleştirme-bağlama (place & route) işlemleri Xilinx "
    "Vivado ortamında yürütülmüş; pin atamaları XDC kısıt dosyası aracılığıyla "
    "tanımlanmıştır. Sistemin saat girişi kart üzerindeki 100 MHz kristal osilatöre "
    "bağlanmış, sıfırlama (reset) sinyali ise bir basma düğmesine (push button) "
    "atanmıştır. (PÇ5)"
)

heading("6.2. Sentez Sonuçları", level=2)
note("Vivado Implementation Summary raporundan LUT, FF, BRAM ve WNS değerlerini buraya girin.")
para(
    "Sentez ve yerleştirme-bağlama aşamaları tamamlandıktan sonra elde edilen kaynak "
    "kullanım raporu Tablo 6.1'de sunulmuştur. Timing analizi, tasarımın belirlenen "
    "saat frekansında kararlı biçimde çalıştığını ve WNS değerinin sıfırın üzerinde "
    "kaldığını doğrulamaktadır. (PÇ5)"
)

tbl_fpga = doc.add_table(rows=6, cols=3)
tbl_fpga.style = "Table Grid"
for j, b in enumerate(["Kaynak", "Kullanılan", "Mevcut (%)"]):
    cell = tbl_fpga.cell(0, j)
    cell.paragraphs[0].clear()
    run = cell.paragraphs[0].add_run(b)
    run.font.name = FONT; run.font.size = SIZE; run.font.bold = True
for i, satir in enumerate([
    ["LUT",         "[Vivado'dan doldurun]", "[%]"],
    ["FF",          "[Vivado'dan doldurun]", "[%]"],
    ["BRAM",        "[Vivado'dan doldurun]", "[%]"],
    ["Maks. Frekans", "[MHz]",              "—"],
    ["WNS",         "[ns]",                 "—"],
]):
    table_row(tbl_fpga, i + 1, satir)
p_tbl3 = doc.add_paragraph()
p_tbl3.paragraph_format.space_after = Pt(8)
run3 = p_tbl3.add_run("Tablo 6.1. FPGA Kaynak Kullanım Raporu")
run3.font.name = FONT; run3.font.size = Pt(9); run3.font.italic = True

heading("6.3. FPGA Üzerinde Doğrulama", level=2)
note("Kartta hangi çıkışların (LED, display vb.) gözlemlendiğini ve demo videosu referansını ekleyin.")
para(
    "Sisteme belirli bir test programı yüklenerek AC yazmacının değeri kart üzerindeki "
    "LED'lerde izlenmiştir. Reset sinyali uygulandıktan sonra program otomatik olarak "
    "yürütülmüş ve LED çıkışlarının beklenen değerlerle örtüştüğü gözlemlenmiştir. "
    "Sistemin çalışmasını belgeleyen demo videosu teslim paketinde sunulmaktadır. (PÇ5)"
)

doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# 7. SONUÇ
# ══════════════════════════════════════════════════════════════════════
heading("7. SONUÇ")
note("Bu bölüm Eren tarafından düzenlenecektir.")
para(
    "Bu çalışmada Mano temel bilgisayarının hardwired kontrol devresi, mikroprogramlanmış "
    "kontrol mimarisine başarıyla dönüştürülmüş; tüm bileşenler VHDL ile gerçeklenerek "
    "FPGA üzerinde doğrulanmıştır. Geliştirilen tasarımda kontrol belleği, tüm Mano "
    "komutlarını kapsayan eksiksiz bir mikroprogram içermekte ve simülasyon testleri "
    "sistemin doğru davranış sergilediğini teyit etmektedir. (PÇ1)"
)
para(
    "Mikroprogramlanmış yaklaşımın en belirgin avantajı, yeni komutların eklenmesinin "
    "yalnızca kontrol belleği içeriğinin güncellenmesiyle mümkün olmasıdır; bu durum "
    "tasarımın genişletilebilirliğini önemli ölçüde artırmaktadır. Öte yandan, her "
    "komutun birden fazla mikro-işlem adımı gerektirmesi, hardwired kontrole kıyasla "
    "daha düşük komut işleme hızına yol açmakta; bu sınırlama performans kritik "
    "uygulamalar için dikkate alınmalıdır. (PÇ5)"
)
para(
    "Proje boyunca dört kişilik grup, görev dağılımı ve düzenli iletişim sayesinde etkin "
    "bir işbirliği sürdürmüştür. Veri yolu tasarımı, kontrol birimi geliştirme, test "
    "ve FPGA gerçekleme aşamaları paralel ilerleyerek teslim tarihine uygun biçimde "
    "tamamlanmıştır. Gelecek çalışmalarda pipeline mimarisi ile performansın artırılması "
    "ve komut setinin genişletilmesi planlanabilir. (PÇ1, PÇ13)"
)
doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# 8. KAYNAKLAR
# ══════════════════════════════════════════════════════════════════════
heading("8. KAYNAKLAR")
for k in [
    "[1]  M. M. Mano, Computer System Architecture, 3rd ed. Upper Saddle",
    "     River, NJ: Prentice Hall, 1993.",
    "[2]  M. M. Mano ve C. R. Kime, Logic and Computer Design Fundamentals,",
    "     4th ed. Upper Saddle River, NJ: Prentice Hall, 2008.",
    "[3]  M. V. Wilkes, 'The best way to design an automatic calculating",
    "     machine,' Manchester Univ. Comp. Inaugural Conf., 1951.",
    "[4]  Xilinx Inc., Vivado Design Suite User Guide, UG910, 2023.",
    "[5]  [Varsa kullandığınız ek kaynak — IEEE formatında]",
]:
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(3)
    p.paragraph_format.left_indent = Cm(0.5)
    run = p.add_run(k)
    run.font.name = FONT
    run.font.size = SIZE

doc.add_page_break()

# ══════════════════════════════════════════════════════════════════════
# EK A — GÖREV DAĞILIMI
# ══════════════════════════════════════════════════════════════════════
heading("EK A — GÖREV DAĞILIMI")
tbl_gorev = doc.add_table(rows=6, cols=3)
tbl_gorev.style = "Table Grid"
for j, b in enumerate(["Kişi", "Görev", "Bölümler"]):
    cell = tbl_gorev.cell(0, j)
    cell.paragraphs[0].clear()
    run = cell.paragraphs[0].add_run(b)
    run.font.name = FONT; run.font.size = SIZE; run.font.bold = True
for i, satir in enumerate([
    ["Kişi 1 (Eren)", "Rapor yazımı, koordinasyon, giriş, sonuç", "2, 7, Ek A"],
    ["Kişi 2",        "Veri yolu bileşenleri (VHDL)",              "4.1, 5.1"],
    ["Kişi 3",        "Mikroprogramlanmış kontrol birimi (VHDL)",   "4.2, 4.3, 4.4, 5.1"],
    ["Kişi 4",        "Test ve simülasyon",                         "5.2"],
    ["Tümü",          "Teorik arka plan, FPGA gerçeklemesi, sunum", "3, 6"],
]):
    table_row(tbl_gorev, i + 1, satir)

# ── Kaydet ────────────────────────────────────────────────────────────
out = "/Users/erenkendir/Desktop/mimari1/Rapor_Iskelet.docx"
doc.save(out)
print(f"Dosya olusturuldu: {out}")
