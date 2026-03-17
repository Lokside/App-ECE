# Règles du projet Proto ECE App DRH

## Règle n°1 : Toutes les données en JSON

Toute information affichée en front (textes, labels, montants, dates, couleurs, URLs d'assets, configurations de widgets, notifications, données de graphiques, etc.) **doit être stockée dans les fichiers JSON du dossier `Proto ECE App DRH/Data/Datasets/`**.

Quand une modification est faite dans l'app :
- Si une nouvelle donnée apparaît dans le front → l'ajouter dans le JSON approprié
- Si une donnée existante est modifiée → mettre à jour le JSON correspondant
- Si une donnée est supprimée → la retirer du JSON

Les fichiers JSON servent de **base de données locale** pour pouvoir réutiliser ces informations ailleurs dans l'app (et plus tard via une IA).

## Règle n°2 : Composants réutilisables

Tout élément visuel qui apparaît plus d'une fois dans l'app **doit être un composant du Design System** (préfixé `D`). Ne jamais coder en dur un style ou un layout qui existe déjà dans `DesignSystem/Components/`.

## Stack technique

- **Plateforme** : iOS natif (SwiftUI)
- **Langage** : Swift 5.0
- **Déploiement minimum** : iOS 17.0
- **Assets** : Xcode Assets catalog + images distantes via Figma API

## Architecture 3 couches

```
Proto ECE App DRH/Proto ECE App DRH/
├── DesignSystem/           ← Tokens + Composants atomiques réutilisables
│   ├── Tokens/             ← ColorTokens, TypographyTokens, SpacingTokens
│   └── Components/         ← DSurfaceCard, DCapsuleBadge, DSectionHeader, DMetricTile…
├── Core/                   ← Utilitaires transversaux
│   ├── Extensions/         ← Bundle+JSON
│   ├── Formatting/         ← AppFormatters
│   └── Theme/              ← BrandTheme (alias sémantiques → consomme les Tokens)
├── Data/                   ← Couche BACK (données)
│   ├── Datasets/           ← Fichiers JSON métier
│   ├── Models/             ← Structs Decodable (HRDatasetModels)
│   └── Repositories/       ← LocalHRRepository (protocole HRRepository)
├── Domain/                 ← Couche MIDDLE (logique métier)
│   ├── Models/             ← Modèles d'affichage (HomeScreenModels)
│   └── Services/           ← DashboardAssembler (transforme Data → Domain)
├── Presentation/           ← Couche FRONT (vues)
│   ├── Components/         ← Ponts métier (MetricTile wraps DMetricTile + model)
│   └── Home/               ← HomeView, HomeViewModel, HomeCards (cartes métier)
├── AppRootView.swift       ← Point d'entrée de la navigation
└── Proto_ECE_App_DRHApp.swift ← @main
```

### Flux de données

```
JSON (Data/Datasets)
  → Decodable models (Data/Models)
    → LocalHRRepository (Data/Repositories)
      → HRRepositorySnapshot
        → DashboardAssembler (Domain/Services)
          → HomeScreenState (Domain/Models)
            → HomeViewModel (Presentation/Home)
              → HomeView + HomeCards (Presentation)
                → Composants DS (DesignSystem/Components)
```
