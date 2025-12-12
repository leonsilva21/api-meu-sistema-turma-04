package br.com.meusistema.api.service;

import br.com.meusistema.api.dtos.LoginRequestDTO;
import br.com.meusistema.api.dtos.LoginResponseDTO;
import br.com.meusistema.api.dtos.RegisterRequestDTO;
import br.com.meusistema.api.dtos.UsuarioResponseDTO;
import br.com.meusistema.api.enums.Role;
import br.com.meusistema.api.model.Usuario;
import br.com.meusistema.api.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public LoginResponseDTO register(RegisterRequestDTO request) {
        Role role = request.role() != null ? request.role() : Role.USER;

        Usuario usuario = Usuario.builder()
                .username(request.username())
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .role(role)
                .build();
        usuarioRepository.save(usuario);

        log.info("Novo usuário registrado: {} ({})", usuario.getUsername(), usuario.getRole());

        UserDetails userDetails = User.builder()
                .username(usuario.getUsername())
                .password(usuario.getPassword())
                .roles(usuario.getRole().name())
                .build();

        String token = jwtService.generateToken(userDetails);
        return new LoginResponseDTO(token);
    }

    public LoginResponseDTO login(LoginRequestDTO request) {
        log.debug("Tentando login para usuário: {}", request.username());

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );

        Usuario usuario = usuarioRepository.findByUsername(request.username())
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado"));

        log.info("Login bem-sucedido para usuário: {}", usuario.getUsername());

        UserDetails userDetails = User.builder()
                .username(usuario.getUsername())
                .password(usuario.getPassword())
                .roles(usuario.getRole().name())
                .build();

        String token = jwtService.generateToken(userDetails);
        return new LoginResponseDTO(token);
    }

    public UsuarioResponseDTO getUsuarioLogado(String username) {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado"));

        log.debug("Consultando dados do usuário logado: {}", username);

        return new UsuarioResponseDTO(
                usuario.getUsername(),
                usuario.getEmail(),
                usuario.getRole()
        );
    }
}
