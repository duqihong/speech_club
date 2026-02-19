class MySpeechDeck {
  final List<String> cards;

  MySpeechDeck({required this.cards});

  factory MySpeechDeck.empty() => MySpeechDeck(cards: <String>[]);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cards': cards,
      };

  factory MySpeechDeck.fromJson(Map<String, dynamic> json) {
    return MySpeechDeck(
      cards: List<String>.from(json['cards'] ?? <String>[]),
    );
  }
}
