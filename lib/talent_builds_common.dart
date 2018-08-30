class Talent {
  final String name;
  final String description;
  final String imageUrl;

  Talent(this.name, this.description, this.imageUrl);

  @override
  String toString() {
    return 'Talent{name: $name, description: $description, imageUrl: $imageUrl}';
  }
}

class TalentBuild {
  final int gameCount;
  final double winPercent;
  final Talent tier1;
  final Talent tier2;
  final Talent tier3;
  final Talent tier4;
  final Talent tier5;
  final Talent tier6;
  final Talent tier7;

  TalentBuild(this.gameCount, this.winPercent, this.tier1, this.tier2,
      this.tier3, this.tier4, this.tier5, this.tier6, this.tier7);

  @override
  String toString() {
    return 'TalentBuild{gameCount: $gameCount, winPercent: $winPercent, tier1: $tier1, tier2: $tier2, tier3: $tier3, tier4: $tier4, tier5: $tier5, tier6: $tier6, tier7: $tier7}';
  }

  Iterable<Talent> iterTalents() sync* {
    yield tier1;
    yield tier2;
    yield tier3;
    yield tier4;
    yield tier5;
    yield tier6;
    yield tier7;
  }

  Iterable<T> mapTalents<T>(T f(Talent t)) => iterTalents().map(f);
}

class FetchTalentBuildException implements Exception {
  final String cause;
  final String details;

  FetchTalentBuildException(this.cause, this.details);

  @override
  String toString() {
    return 'FetchTalentBuildException{cause: $cause, details: $details}';
  }
}