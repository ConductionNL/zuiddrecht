# Gemeente Zuiddrecht

Een demo-omgeving van de gemeente Zuiddrecht. Die gemeente bestaat niet. U start een eigen Nextcloud-werkplek in de huisstijl van Zuiddrecht, met medewerkers, groepen en startpagina's al ingevuld. Zo probeert u zelf hoe een gemeentelijke werkplek op Nextcloud werkt.

De omgeving bevat:

- **Nextcloud 34**, de werkplek zelf.
- **[Thematiq](https://github.com/ConductionNL/thematiq)**, met het thema Zuiddrecht: kleuren, lettertype, logo en de driekleurige streep.
- **[Launchpad](https://github.com/ConductionNL/launchpad)**, de startpagina. Elke medewerker landt op een eigen dashboard.

## Starten

U heeft [Docker](https://docs.docker.com/get-docker/) met Docker Compose nodig.

```bash
git clone https://github.com/ConductionNL/zuiddrecht.git
cd zuiddrecht
docker compose up -d
```

De images bevatten een Nextcloud die al is geïnstalleerd, met thema en demo erin. Na het downloaden van de images is de werkplek binnen enkele seconden klaar. Daarna opent u <http://localhost:8080>.

`docker compose ps` toont `healthy` bij de werkplek zodra alles klaar is.

## Inloggen

Alle demo-medewerkers hebben het wachtwoord `Zuiddrecht-demo-2026!`.

| Gebruiker | Wie | Wat u ziet |
|---|---|---|
| `pieter` | Pieter Jansen, vergunningen | Vandaag, Mijn werkplek, Intranet, Team Vergunningen, Managementinformatie |
| `marieke` | Marieke Jansen, teamleider vergunningen | Beheert het dashboard van Team Vergunningen |
| `sanne` | Sanne de Vries, vergunningen | Team Vergunningen, mag widgets toevoegen |
| `hanneke` | Hanneke Visser, directie | Managementinformatie |
| `communicatie` | Team Communicatie | Beheert het Intranet Zuiddrecht |
| `beheer` | Functioneel beheerder | De beheerpagina's |
| `nieuw` | Noor Nieuw, net in dienst | Het eerste bezoek, nog zonder dashboard |

De beheerder is `admin` met wachtwoord `admin`. De volledige lijst staat in de [documentatie van Launchpad](https://github.com/ConductionNL/launchpad/blob/development/docs/features/demo-seed.md).

Gebruik deze omgeving alleen als demo. De wachtwoorden zijn openbaar.

## Instellen

Kopieer `.env.example` naar `.env` en pas aan wat u wilt. Zonder `.env` gelden de standaardwaarden.

| Instelling | Standaard | Betekenis |
|---|---|---|
| `PORT` | `8080` | Poort op uw computer |
| `ADMIN_PASSWORD` | `admin` | Wachtwoord van de beheerder |
| `DEMO_PASSWORD` | leeg | Ander wachtwoord voor de demo-medewerkers |
| `DEMO_LANGUAGE` | `nl` | Taal van de dashboards: `nl` of `en` |
| `ZUIDDRECHT_TAG` | `latest` | Versie van de image |

Deze instellingen werken bij de eerste start van de werkplek. Wijzigt u ze later, begin dan opnieuw. Met `DEMO_LANGUAGE=en` laadt de eerste start de dashboards opnieuw in het Engels. Dat kost ongeveer twintig seconden extra.

## Opnieuw beginnen

```bash
docker compose down
docker compose up -d
```

De demo leeft in de containers, niet in volumes. `down` wist dus alle gegevens en de volgende start zet de demo weer schoon neer. Wilt u de werkplek pauzeren zonder iets kwijt te raken, gebruik dan `docker compose stop` en later `docker compose start`.

## Op een server zetten

Zet de werkplek achter een reverse proxy met HTTPS en vul in `.env` uw domein in:

```bash
TRUSTED_DOMAINS=localhost zuiddrecht.example.nl
OVERWRITE_PROTOCOL=https
OVERWRITE_CLI_URL=https://zuiddrecht.example.nl
```

Kies dan ook een eigen `ADMIN_PASSWORD` en `DEMO_PASSWORD`.

Elke kopie van de images bevat dezelfde installatie. Twee waarden zijn daardoor overal gelijk: de `instanceid` van Nextcloud en het wachtwoord waarmee Nextcloud de database gebruikt. De database is alleen bereikbaar binnen het Docker-netwerk van de demo. De geheime sleutel (`secret`) en de `passwordsalt` zijn wel uniek. Een nieuwe container maakt die bij de eerste start zelf aan.

## Hoe het werkt

De demo bestaat uit twee images. `ghcr.io/conductionnl/zuiddrecht` is de officiële Nextcloud-image met Thematiq en Launchpad, al geïnstalleerd en gevuld. `ghcr.io/conductionnl/zuiddrecht-db` is PostgreSQL met de bijbehorende database. Er wordt bij het starten dus niets gedownload of geïnstalleerd.

Die installatie maakt [`snapshot/build.sh`](snapshot/build.sh). Het script start Nextcloud één keer met een lege database en draait [`snapshot/seed.sh`](snapshot/seed.sh). Dat zet de apps aan, kiest het thema en laadt de demo. Het resultaat is een SQL-dump en de map met gegevens. Die werken op elke processor, dus dezelfde snapshot dient amd64 en arm64.

De versies van de apps staan in de [`Dockerfile`](Dockerfile). Een wijziging op `main` bouwt en publiceert nieuwe images. Wilt u zelf bouwen:

```bash
snapshot/build.sh
docker build --target db -t ghcr.io/conductionnl/zuiddrecht-db .
docker build -t ghcr.io/conductionnl/zuiddrecht .
docker compose up -d --pull never
```

Widgets die gegevens uit andere apps tonen, zoals zaken, blijven leeg. Die apps zitten niet in deze demo. Het weerbericht heeft internettoegang nodig.

## Licentie

[EUPL-1.2](LICENSE). Gemaakt door [Conduction](https://conduction.nl).
