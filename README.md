# Visual Novel & Text-RPG Engine

Strukturalny silnik gry tekstowej (Visual Novel / Text-RPG) napisany w języku Ruby. Projekt opiera się na separacji statycznych zasobów gry (szablonów ładowanych z plików konfiguracji) od dynamicznego stanu rozgrywki, który może być zapisywany i wczytywany w dowolnym momencie.

## Architektura Systemu

Silnik został zaprojektowany z podziałem na warstwę danych (Model), zarządzania zasobami (Managers) oraz pętli rozgrywki (Controller).

* **Game** – Główny kontroler zarządzający menu, interakcją z użytkownikiem oraz pętlą gry (`game_loop`).
* **AssetManager** – Odpowiada za wczytanie z plików YAML wszystkich niezmiennych danych gry (szablonów lokacji, przedmiotów, postaci oraz grafu dialogowego) i połączenie ich referencjami w pamięci (`link_everything`).
* **GameState** – Przechowuje dynamiczny, aktualny stan gry (aktualny pokój, pozycje przedmiotów/postaci, relacje, flagi fabularne oraz czas).
* **DataManager** – Serializuje dynamiczny stan gry do plików zapisu (`.yaml`) oraz przywraca go przy kontynuacji gry.
* **DialogueManager** – Odpowiada za interpretację grafu dialogowego, weryfikację warunków (`Requirement`) opcji dialogowych oraz aplikowanie ich skutków (`Effect`).

---

## Diagram Klas

*Tutaj możesz osadzić swój diagram klas z pliku projektu:*
![Diagram Klas](diagram.jpg)

---

## Struktura Zasobów (Assets)

Gra jest w pełni konfigurowalna za pomocą plików tekstowych w formacie YAML, które powinny znajdować się w katalogu danej gry (np. `games/nazwa_gry/assets/`).

### 1. Wymagania (requirements.yaml)
Definiują warunki, które muszą zostać spełnione, aby dialog był dostępny lub opcja możliwa do wyboru:
```yaml
- id: "req_location"
  type: "location"
  loc_id: "Place"

- id: "req_relation"
  type: "min_relation"
  char_id: "Character"
  value: 5 

- id: "req_flag"
  type: "flag"
  flag: "Flag_name"

- id: "req_item"
  type: "has_item"
  item_id: "Item"
```

### 2. Efekty (effects.yaml)
Definiują konsekwencje wyborów gracza (zmiana relacji, dodanie/usunięcie przedmiotów, ustawienie flagi):

```yaml
- id: "eff_add_relation"
  type: "relation"
  char_id: "Character"
  value: 2

- id: "eff_minus_relation"
  type: "relation"
  char_id: "Character"
  value: -2

- id: "eff_get_item"
  type: "add_item"
  item_id: "Item"

- id: "eff_get_flag"
  type: "add_flag"
  item_id: "Flag_name"

- id: "eff_remove_item"
  type: "remove_item"
  item_id: "Item"
```
  
### 3. Opcje i Dialogi (options.yaml & dialogues.yaml)
Dialogi składają się z kwestii mówionej oraz tablicy opcji wyboru. Opcje mogą prowadzić do kolejnych węzłów dialogu (next_dial):

```yaml
# dialogues.yaml
- id: "dial_start"
  character: "Character_name"
  text: "Hello there! [...]"
  reqs: ["req_loc_must", "optional_req_other"]
  options: ["opt_give_donut", "opt_say_no"]

```
Tutaj uwaga: Wyłącznie dialogi startowe mogą mieć wymagania, tylko one będą sprawdzane. Dialogi startowe muszą też mieć wymaganie typu location. Jeśli dialog jest uniwersalny to jako room_id należy podać 'any'.
reqs i options przechowują id elementów stworzonych w odpowiednich plikach.

```yaml
# options.yaml
- id: "opt_char_greeting"
  text: "Hello World! [...]"
  reqs:
    - "req_has_item"
  effects:
    - "eff_remove_item"
    - "eff_plus_relation"
    - "eff_set_flag"
  next_dial: "dial_thank_you"

- id: "opt_end"
  text: "(End the dialogue)"
  reqs: []
  effects: []
  next_dial: null

```
Dialogi muszą miec podane co najmniej jedna opcję. Jeśli dialog jest kończący to musi byc podana opcja analogiczna do "opt_end" z powyższego przykładu. Ta opcja nadal może mieć reqs i effects, ale next_dial musi być równy null. To kończy dialog.

### 4. Postacie, pokoje i przedmioty (characters.yaml & rooms.yaml & items.yaml)

```yaml
#characters.yaml
- name: "Character_name"
  description: "A fun fact about Character"
```

```yaml
#items.yaml
- name: "Item"
  description: "A fun fact about Item"
```

```yaml
#rooms.yaml
- name: "Room"
  description: "A description of room"
```
Dla wszystkich przedmiotów name odpowiada id. Jeśli w requirements potrzebne jest np. item_id to powinno sie podać name istniejącego w items.yaml obiektu. Analogicznie dla rooms i characters.
   
## Uruchomienie Projektu
Wykonaj poniższe polecenie w katalogu głównym projektu, aby uruchomić grę:

ruby visual_novel_game/main.rb

## System zapisu gier
Zapisy tworzone są automatycznie wewnątrz podkatalogu gry: games/<tytuł_gry>/saves/*.yaml. Silnik samodzielnie weryfikuje istnienie folderów i tworzy je w razie potrzeby.

## Mechanika Czasu
Część interakcji (rozmowa, zmiana pokoju) zużywa czas (Round). Po osiągnięciu limitu rund (max_round = 10), dzień gry ulega zmianie, wywoływana jest metoda new_day, a pozycje postaci i przedmiotów w świecie gry są losowane na nowo.
