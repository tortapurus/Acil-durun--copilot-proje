// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      ad: fields[1] as String,
      kategori: fields[2] as String,
      sonKullanmaTarihi: fields[3] as DateTime,
      hatirlatmaTarihi: fields[4] as DateTime,
      notlar: fields[5] as String?,
      konum: fields[6] as String?,
      resimYolu: fields[7] as String?,
      kontrolEdildi: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ad)
      ..writeByte(2)
      ..write(obj.kategori)
      ..writeByte(3)
      ..write(obj.sonKullanmaTarihi)
      ..writeByte(4)
      ..write(obj.hatirlatmaTarihi)
      ..writeByte(5)
      ..write(obj.notlar)
      ..writeByte(6)
      ..write(obj.konum)
      ..writeByte(7)
      ..write(obj.resimYolu)
      ..writeByte(8)
      ..write(obj.kontrolEdildi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
