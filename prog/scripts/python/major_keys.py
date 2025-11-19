import random

major_scales = {
    "C":  ["C", "D", "E", "F", "G", "A", "B"],
    "Db": ["Db", "Eb", "F", "Gb", "Ab", "Bb", "C"],
    "D":  ["D", "E", "F#", "G", "A", "B", "C#"],
    "Eb": ["Eb", "F", "G", "Ab", "Bb", "C", "D"],
    "E":  ["E", "F#", "G#", "A", "B", "C#", "D#"],
    "F":  ["F", "G", "A", "Bb", "C", "D", "E"],
    "F#": ["F#", "G#", "A#", "B", "C#", "D#", "E#"],
    "G":  ["G", "A", "B", "C", "D", "E", "F#"],
    "Ab": ["Ab", "Bb", "C", "Db", "Eb", "F", "G"],
    "A":  ["A", "B", "C#", "D", "E", "F#", "G#"],
    "Bb": ["Bb", "C", "D", "Eb", "F", "G", "A"],
    "B":  ["B", "C#", "D#", "E", "F#", "G#", "A#"],
}

print("Available scales:")
print(", ".join(major_scales.keys()))

scale_name = input("Choose a scale: ").strip()
if scale_name not in major_scales:
    print("Scale not found!")
    exit()

scale = major_scales[scale_name]

print(f"\nTraining in {scale_name} major scale: {', '.join(scale)}")
print("Type the note for the given degree (1–7). Type 'q' to quit.\n")

last_degree = None

while True:
    degree = random.choice([d for d in range(1, 8) if d != last_degree])
    last_degree = degree
    correct_note = scale[degree - 1]

    answer = input(f"Degree {degree}: ").strip()

    if answer.lower() == "q":
        print("Goodbye!")
        break

    if answer.lower() == correct_note.lower():
        print("✅ Correct!\n")
    else:
        print(f"❌ Wrong. Correct answer: {correct_note}\n")
