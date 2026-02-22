# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-02-02

### Added - Major Release! 🚀

#### Multiple Event Types
- ✅ Fetch event (read data)
- ✅ Create event (insert new data)
- ✅ Update event (modify existing data)
- ✅ Delete event (remove data)
- ✅ Refresh event (re-fetch data)
- Mix and match any combination of events

#### Configurable States
- ✅ Standard states: Initial, Loading, Loaded, Error
- ✅ Optional Empty state (for no data scenarios)
- ✅ Optional Creating state (for create operations)
- ✅ Optional Updating state (for update operations)
- ✅ Optional Deleting state (for delete operations)
- Better UX with operation-specific states

#### Repository Layer Support
- ✅ Optional repository generation
- ✅ Clean architecture separation
- ✅ Repository interface + implementation
- ✅ Easy to mock for testing
- ✅ Centralized error handling

#### Interactive CLI
- ✅ Step-by-step prompts for all options
- ✅ Smart defaults
- ✅ Or use command-line flags
- ✅ Clear descriptions for each option

#### Smart Features
- ✅ Auto-refresh after create/update/delete
- ✅ Empty state detection for lists
- ✅ Operation-specific loading states
- ✅ Configurable method names
- ✅ Triple braces for no HTML encoding

#### Code Quality
- ✅ Full Equatable support (optional)
- ✅ Type-safe generics
- ✅ Null-safe code
- ✅ Clean, formatted output
- ✅ Follows BLoC best practices

### Technical Details

#### New Configuration Variables
- `use_repository` - Generate repository layer
- `include_fetch` - Include fetch event
- `include_create` - Include create event
- `include_update` - Include update event
- `include_delete` - Include delete event
- `include_refresh` - Include refresh event
- `include_empty_state` - Add Empty state
- `include_creating_state` - Add Creating state
- `include_updating_state` - Add Updating state
- `include_deleting_state` - Add Deleting state
- `fetch_method` - Custom fetch method name
- `create_method` - Custom create method name
- `update_method` - Custom update method name
- `delete_method` - Custom delete method name

#### Generated Files
- `{name}_bloc.dart` - BLoC with selected events
- `{name}_event.dart` - Events based on selections
- `{name}_state.dart` - States based on selections
- `{name}_repository.dart` - Optional repository (if use_repository = true)

#### Event Handlers
Each selected event generates:
- Complete handler method
- Proper state emissions
- Error handling
- Auto-refresh logic (for mutations)

### Simple Use

```bash
# Use Advanced BLoC for complex cases
mason make advanced_bloc
```

**Not a breaking change** - Both versions can coexist!

### Examples

#### Example 1: Full CRUD
```bash
mason make advanced_bloc \
  --name user \
  --include_fetch \
  --include_create \
  --include_update \
  --include_delete
```

#### Example 2: With Repository
```bash
mason make advanced_bloc \
  --name product \
  --use_repository \
  --include_fetch \
  --include_create
```

#### Example 3: Simple Fetch with Empty State
```bash
mason make advanced_bloc \
  --name post \
  --include_fetch \
  --include_empty_state
```

### Performance

- Generation time: ~100ms (similar to v1.0)
- No runtime overhead
- Clean generated code
- No external dependencies (except flutter_bloc, equatable)

### Documentation

- Complete README with examples
- Quick start guide
- API reference
- Best practices
- Migration guide

### Known Limitations

- Delete event assumes String ID (can be customized in generated code)
- Auto-refresh uses Fetch event (requires Fetch to be enabled)
- Repository layer is simple pass-through (add custom logic as needed)

### Roadmap

#### v2.1 (Minor)
- Pagination support
- Search/filter events
- Better error types

#### v3.0 (Major)
- Freezed integration
- Infinite scroll support
- Offline-first with caching
- WebSocket events
- GraphQL support

## [1.0.0] - 2026-01-28

### Added - Initial Release

- Basic BLoC generation
- 4 states: Initial, Loading, Loaded, Error
- 1 event: Fetch
- Datasource integration
- Equatable support (optional)
- Clean, simple templates

---

For upgrade instructions and detailed changes, see [README.md](README.md)