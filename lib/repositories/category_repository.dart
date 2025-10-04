import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all categories from the database
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      final categories = response
          .map((json) => Category.fromJson(json))
          .toList();
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get a specific category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('id', id)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        // No rows found
        return null;
      }
      throw Exception('Failed to fetch category: $e');
    }
  }

  /// Get a specific category by name
  Future<Category?> getCategoryByName(String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('name', name)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        // No rows found
        return null;
      }
      throw Exception('Failed to fetch category by name: $e');
    }
  }

  /// Create a new category
  Future<Category> createCategory(String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .insert({'name': name})
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update an existing category
  Future<Category> updateCategory(String id, String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
