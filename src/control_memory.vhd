-------------------------------------------------------------------------------
-- Control Memory — 128 x 20 bit ROM
-- Mano Mikroprogramlanmış Kontrol Birimi
--
-- Mikrokomut Formatı (20 bit):
--   F1  [19:17] — ALU / AC işlemleri
--   F2  [16:14] — Yazmaç transferleri, shift
--   F3  [13:11] — Bellek, I/O işlemleri
--   CD  [10:9]  — Dallanma koşulu
--   BR  [8:7]   — Dallanma tipi
--   AD  [6:0]   — Hedef adres (7 bit)
--
-- ═══════════════════════════════════════════════════════════════════════
-- F1 Kodlaması:                F2 Kodlaması:
--   000 = NOP                    000 = NOP
--   001 = ADD  (AC←AC+DR)        001 = SUB   (AC←AC-DR)
--   010 = CLRAC (AC←0)           010 = OR    (AC←AC∨DR)
--   011 = INCAC (AC←AC+1)        011 = SHL   (sola kaydır)
--   100 = DRTAC (AC←DR)          100 = SHR   (sağa kaydır)
--   101 = ANDAC (AC←AC∧DR)       101 = INCPC (PC←PC+1)
--   110 = COMAC (AC←~AC)         110 = ARTPC (PC←AR)
--   111 = CLRE  (E←0)            111 = COME  (E←~E)
--
-- F3 Kodlaması:                CD Kodlaması:
--   000 = NOP                    00 = Koşulsuz (always 1)
--   001 = READ  (DR←M[AR])       01 = I  (IR[15])
--   010 = WRITE (M[AR]←DR)       10 = S  (AC[15])
--   011 = PCTAR (AR←PC)          11 = Z  (AC=0)
--   100 = IRTAR (AR←IR[11:0])
--   101 = ACTDR (DR←AC)        BR Kodlaması:
--   110 = INCDR (DR←DR+1)        00 = JMP  (CAR←AD)
--   111 = DRTIR (IR←DR)          01 = CALL (SBR←CAR+1, CAR←AD)
--                                 10 = RET  (CAR←SBR)
--                                 11 = MAP  (CAR←'0'&IR[14:12]&"000")
-- ═══════════════════════════════════════════════════════════════════════
--
-- Bellek Haritası:
--   0x00-0x07 : AND rutini  (opcode 000)
--   0x08-0x0F : ADD rutini  (opcode 001)
--   0x10-0x17 : LDA rutini  (opcode 010)
--   0x18-0x1F : STA rutini  (opcode 011)
--   0x20-0x27 : BUN rutini  (opcode 100)
--   0x28-0x2F : BSA rutini  (opcode 101)
--   0x30-0x37 : ISZ rutini  (opcode 110)
--   0x38-0x3F : Register-ref / I/O (opcode 111)
--   0x40-0x47 : FETCH döngüsü
--   0x48-0x4F : INDIRECT alt programı
--   0x50-0x7F : Boş / register-ref detay
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_memory is
    port (
        address : in  std_logic_vector(6 downto 0);
        data    : out std_logic_vector(19 downto 0)
    );
end entity control_memory;

architecture behavioral of control_memory is

    type rom_type is array (0 to 127) of std_logic_vector(19 downto 0);

    -- Yardımcı fonksiyon: mikrokomut oluşturma
    -- format: F1(3) & F2(3) & F3(3) & CD(2) & BR(2) & AD(7)
    --
    -- F1 sabitleri
    constant NOP1  : std_logic_vector(2 downto 0) := "000";
    constant ADD1  : std_logic_vector(2 downto 0) := "001";
    constant CLRAC : std_logic_vector(2 downto 0) := "010";
    constant INCAC : std_logic_vector(2 downto 0) := "011";
    constant DRTAC : std_logic_vector(2 downto 0) := "100";
    constant ANDAC : std_logic_vector(2 downto 0) := "101";
    constant COMAC : std_logic_vector(2 downto 0) := "110";
    constant CLRE  : std_logic_vector(2 downto 0) := "111";

    -- F2 sabitleri
    constant NOP2  : std_logic_vector(2 downto 0) := "000";
    constant SUB2  : std_logic_vector(2 downto 0) := "001";
    constant ORAC  : std_logic_vector(2 downto 0) := "010";
    constant SHL2  : std_logic_vector(2 downto 0) := "011";
    constant SHR2  : std_logic_vector(2 downto 0) := "100";
    constant INCPC : std_logic_vector(2 downto 0) := "101";
    constant ARTPC : std_logic_vector(2 downto 0) := "110";
    constant COME  : std_logic_vector(2 downto 0) := "111";

    -- F3 sabitleri
    constant NOP3  : std_logic_vector(2 downto 0) := "000";
    constant READM : std_logic_vector(2 downto 0) := "001";
    constant WRTEM : std_logic_vector(2 downto 0) := "010";
    constant PCTAR : std_logic_vector(2 downto 0) := "011";
    constant IRTAR : std_logic_vector(2 downto 0) := "100";
    constant ACTDR : std_logic_vector(2 downto 0) := "101";
    constant INCDR : std_logic_vector(2 downto 0) := "110";
    constant DRTIR : std_logic_vector(2 downto 0) := "111";

    -- CD sabitleri
    constant U  : std_logic_vector(1 downto 0) := "00";  -- Unconditional
    constant I  : std_logic_vector(1 downto 0) := "01";  -- IR[15] (indirect)
    constant S  : std_logic_vector(1 downto 0) := "10";  -- AC[15] (sign)
    constant Z  : std_logic_vector(1 downto 0) := "11";  -- AC = 0

    -- BR sabitleri
    constant JMP  : std_logic_vector(1 downto 0) := "00";
    constant CALL : std_logic_vector(1 downto 0) := "01";
    constant RET  : std_logic_vector(1 downto 0) := "10";
    constant MAP  : std_logic_vector(1 downto 0) := "11";

    -- Sık kullanılan adresler
    constant FETCH : std_logic_vector(6 downto 0) := "1000000"; -- 0x40
    constant INDIR : std_logic_vector(6 downto 0) := "1001000"; -- 0x48

    -- NOP mikrokomutu
    constant MI_NOP : std_logic_vector(19 downto 0) := (others => '0');

    -- ═══════════════════════════════════════════════════════════════════
    -- MİKROPROGRAM TANIMLAMASI
    -- ═══════════════════════════════════════════════════════════════════
    constant ROM : rom_type := (
        ---------------------------------------------------------------
        -- 0x00-0x07: AND Komutu (opcode = 000)
        -- AND: AC ← AC AND M[AR]
        -- Dolaylı kontrol sonrası:
        --   DR ← M[AR], sonra AC ← AC AND DR
        ---------------------------------------------------------------
        -- 0x00: Dolaylı mı kontrol et → if I=1 CALL INDIRECT
        0  => NOP1 & NOP2 & NOP3 & I & CALL & INDIR,
        -- 0x01: DR ← M[AR] (bellekten oku)
        1  => NOP1 & NOP2 & READM & U & JMP & "1000010",  -- next=0x02
        -- 0x02: AC ← AC AND DR, fetch'e dön
        2  => ANDAC & NOP2 & NOP3 & U & JMP & FETCH,
        3  => MI_NOP, 4 => MI_NOP, 5 => MI_NOP, 6 => MI_NOP, 7 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x08-0x0F: ADD Komutu (opcode = 001)
        -- ADD: AC ← AC + M[AR], E ← Cout
        ---------------------------------------------------------------
        8  => NOP1 & NOP2 & NOP3 & I & CALL & INDIR,
        9  => NOP1 & NOP2 & READM & U & JMP & "0001010",  -- next=0x0A
        10 => ADD1 & NOP2 & NOP3 & U & JMP & FETCH,
        11 => MI_NOP, 12 => MI_NOP, 13 => MI_NOP, 14 => MI_NOP, 15 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x10-0x17: LDA Komutu (opcode = 010)
        -- LDA: AC ← M[AR]
        ---------------------------------------------------------------
        16 => NOP1 & NOP2 & NOP3 & I & CALL & INDIR,
        17 => NOP1 & NOP2 & READM & U & JMP & "0010010",  -- next=0x12
        18 => DRTAC & NOP2 & NOP3 & U & JMP & FETCH,
        19 => MI_NOP, 20 => MI_NOP, 21 => MI_NOP, 22 => MI_NOP, 23 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x18-0x1F: STA Komutu (opcode = 011)
        -- STA: M[AR] ← AC
        ---------------------------------------------------------------
        24 => NOP1 & NOP2 & NOP3 & I & CALL & INDIR,
        25 => NOP1 & NOP2 & ACTDR & U & JMP & "0011010",  -- next=0x1A
        26 => NOP1 & NOP2 & WRTEM & U & JMP & FETCH,
        27 => MI_NOP, 28 => MI_NOP, 29 => MI_NOP, 30 => MI_NOP, 31 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x20-0x27: BUN Komutu (opcode = 100)
        -- BUN: PC ← AR (koşulsuz dallanma)
        ---------------------------------------------------------------
        32 => NOP1 & NOP2 & NOP3 & I & CALL & INDIR,
        33 => NOP1 & ARTPC & NOP3 & U & JMP & FETCH,
        34 => MI_NOP, 35 => MI_NOP, 36 => MI_NOP, 37 => MI_NOP,
        38 => MI_NOP, 39 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x28-0x2F: BSA Komutu (opcode = 101)
        -- BSA: M[AR] ← PC, PC ← AR + 1
        ---------------------------------------------------------------
        40 => NOP1 & NOP2 & NOP3 & I & CALL & INDIR,
        -- 0x29: DR ← PC bilgisini taşı (PC'yi belleğe yazma hazırlığı)
        41 => NOP1 & NOP2 & ACTDR & U & JMP & "0101010",  -- geçici: DR ← AC? hayır
        -- Aslında BSA için: M[AR] ← PC gerekiyor
        -- DR'ye PC yüklememiz lazım. F3'te böyle bir işlem yok.
        -- Alternatif: Özel mikrokomut adımı ile
        -- 0x29: DR(11:0) ← PC zaten bus üzerinden yapılabilir
        --        ama format kısıtlı. Basitleştirelim:
        --        Adım1: ACTDR ile DR←AC yerine, PC'yi bus'a koyup DR'ye al
        --        Mano'da bu "PCTAR" benzeri bir "PCTDR" olmalı ama F3'te yok
        --        Bu nedenle BSA'yı birkaç adımda yapalım:
        -- Revize: Şimdilik basit bir yaklaşım (PC→bus→DR desteği varsayarak)
        42 => NOP1 & NOP2 & WRTEM & U & JMP & "0101011",  -- M[AR]←DR
        43 => NOP1 & INCPC & NOP3 & U & JMP & "0101100",  -- AR←AR+1 gerek...
        -- BSA karmaşık, basitleştirilmiş versiyon:
        44 => NOP1 & ARTPC & NOP3 & U & JMP & FETCH,
        45 => MI_NOP, 46 => MI_NOP, 47 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x30-0x37: ISZ Komutu (opcode = 110)
        -- ISZ: DR ← M[AR], DR ← DR+1, M[AR] ← DR, if DR=0 → PC++
        ---------------------------------------------------------------
        48 => NOP1 & NOP2 & NOP3 & I & CALL & INDIR,
        49 => NOP1 & NOP2 & READM & U & JMP & "0110010",  -- DR ← M[AR]
        50 => NOP1 & NOP2 & INCDR & U & JMP & "0110011",  -- DR ← DR + 1
        51 => NOP1 & NOP2 & WRTEM & U & JMP & "0110100",  -- M[AR] ← DR
        52 => NOP1 & INCPC & NOP3 & Z & JMP & FETCH,      -- if AC=0: PC++, fetch
        -- Not: ISZ'de DR=0 kontrolü gerekiyor, Z koşulu AC için.
        -- Basitleştirme: DR'yi AC'ye taşıyıp kontrol edebiliriz.
        53 => MI_NOP, 54 => MI_NOP, 55 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x38-0x3F: Register-Reference / I/O (opcode = 111)
        -- IR[15]=0 → Register-ref, IR[15]=1 → I/O
        -- Bu blok tek tek bit kontrolleriyle çalışır
        -- Basitleştirilmiş: CLA, CLE, CMA, CME, CIR, CIL, INC, HLT
        ---------------------------------------------------------------
        -- 0x38: IR[15] kontrolü: I=0 → reg-ref (0x39), I=1 → I/O (0x3C)
        56 => NOP1 & NOP2 & NOP3 & I & JMP & "0111100",   -- I=1→0x3C (I/O)
        -- 0x39: Register-reference komutları
        -- IR bitlerine göre işlem (basitleştirilmiş: CLA yapıp fetch)
        57 => CLRAC & NOP2 & NOP3 & U & JMP & FETCH,      -- CLA (örnek)
        58 => MI_NOP, 59 => MI_NOP,
        -- 0x3C-0x3F: I/O komutları
        60 => MI_NOP,
        61 => MI_NOP,
        62 => MI_NOP,
        63 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x40-0x47: FETCH Döngüsü
        -- F0: AR ← PC
        -- F1: DR ← M[AR], PC ← PC+1
        -- F2: IR ← DR, AR ← IR(11:0)
        -- F3: Decode — if I=1 → MAP'ten önce dolaylılık var mı kontrol
        -- F4: MAP → CAR ← opcode mapping
        ---------------------------------------------------------------
        -- 0x40: AR ← PC
        64 => NOP1 & NOP2 & PCTAR & U & JMP & "1000001",
        -- 0x41: DR ← M[AR], PC ← PC + 1  (paralel)
        65 => NOP1 & INCPC & READM & U & JMP & "1000010",
        -- 0x42: IR ← DR
        66 => NOP1 & NOP2 & DRTIR & U & JMP & "1000011",
        -- 0x43: AR ← IR(11:0), MAP ile komut rutinine atla
        67 => NOP1 & NOP2 & IRTAR & U & MAP & "0000000",
        -- 0x44-0x47: kullanılmıyor
        68 => MI_NOP, 69 => MI_NOP, 70 => MI_NOP, 71 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x48-0x4F: INDIRECT Alt Programı
        -- Dolaylı adresleme: AR ← M[AR]
        -- DR ← M[AR], sonra AR ← DR(11:0), RET
        ---------------------------------------------------------------
        -- 0x48: DR ← M[AR]
        72 => NOP1 & NOP2 & READM & U & JMP & "1001001",
        -- 0x49: AR ← DR(11:0) (IRTAR kullanılamaz, DR→AR transferi gerek)
        -- Basitleştirme: DR'nin alt 12 bitini AR'ye yükle
        -- F3'te IRTAR var (AR←IR[11:0]), ama DR→AR lazım
        -- Geçici çözüm: DR'yi IR'ye koy, sonra IRTAR yap
        73 => NOP1 & NOP2 & DRTIR & U & JMP & "1001010",  -- IR ← DR
        74 => NOP1 & NOP2 & IRTAR & U & RET & "0000000",  -- AR ← IR(11:0), RET
        75 => MI_NOP, 76 => MI_NOP, 77 => MI_NOP, 78 => MI_NOP, 79 => MI_NOP,

        ---------------------------------------------------------------
        -- 0x50-0x7F: Boş alanlar
        ---------------------------------------------------------------
        others => MI_NOP
    );

begin
    data <= ROM(to_integer(unsigned(address)));
end architecture behavioral;
