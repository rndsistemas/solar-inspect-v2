# SOLAR INSPECT — Fase 2

Aplicativo nativo para iPhone em SwiftUI, estruturado para inspeção, manutenção e georreferenciamento de parques solares.

## Abrir no Xcode

1. Clone ou baixe este repositório.
2. Em um Mac com Xcode, abra `SolarInspect.xcodeproj`.
3. Selecione o target `SolarInspect`.
4. Em **Signing & Capabilities**, escolha sua equipe Apple.
5. Conecte o iPhone e selecione-o como destino.
6. Pressione **Run**.

O projeto está configurado para iOS 17+ e usa o bundle identifier `com.rndsistemas.solarinspect`. Caso esse identificador já esteja registrado em outra conta Apple, altere-o no target do Xcode.

## Estrutura funcional

- Login e perfis
- Dashboard
- Mapa georreferenciado do complexo
- Parques > blocos > mesas/trackers > strings > módulos
- Ficha e histórico do módulo
- Inspeção visual, elétrica, drone e termografia
- Fotos/evidências com metadados
- QR Code
- Ordens de serviço
- Assinatura digital
- Importação KML/KMZ/GeoJSON/CSV
- Estrutura para DWG/DXF convertido
- Notificações
- Sincronização offline/nuvem
- API/ERP

## Tecnologias

- SwiftUI
- MapKit
- CoreLocation
- PhotosUI
- AVFoundation para câmera/QR Code
- UserNotifications
- Supabase
- PostgreSQL + PostGIS
- Object Storage
- REST API

## Permissões iOS

O `Info.plist` já contém descrições de uso para localização, câmera e biblioteca de fotos.

## Estado atual

A interface, modelos, mapa demonstrativo e fluxos principais estão no repositório. As integrações de produção com Supabase/PostGIS, autenticação real, push remoto, mapas GIS completos, armazenamento em nuvem, processamento térmico/IA e ERP ainda precisam de credenciais e backend configurados.
